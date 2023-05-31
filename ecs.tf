resource "aws_ecs_cluster" "cluster" {
  name = "${var.project}-api"

  tags = local.tags
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family             = "node-api"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name : var.project,
      image : var.target_image,
      environment : [
        { "name" : "PORT", "value" : "80" },
        { "name" : "DATABASE_URL", "value" : var.db_connexion_string }
      ],
      portMappings : [
        {
          "name" : "http",
          "containerPort" : 80,
          "hostPort" : 80,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      essential : true,
      logConfiguration : {
        logDriver : "awslogs",
        options : {
          awslogs-create-group : "true",
          awslogs-group : "/ecs/${var.project}",
          awslogs-region : "us-east-1",
          awslogs-stream-prefix : "ecs"
        }
      }
    }
  ])

  cpu          = 1024
  memory       = 2048
  network_mode = "awsvpc"

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_service" "api_service" {
  name                              = var.project
  cluster                           = aws_ecs_cluster.cluster.id
  task_definition                   = element(aws_ecs_task_definition.task_definition.*.arn, 0)
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 60

  load_balancer {
    target_group_arn = aws_lb_target_group.load_balancer_target_group_api.arn
    container_name   = var.project
    container_port   = 80
  }

  network_configuration {
    security_groups  = [aws_security_group.security_group_api_service.id]
    subnets          = var.private_subnets_ids
    assign_public_ip = true
  }
}
