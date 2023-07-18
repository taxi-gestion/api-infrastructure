variable "terraform_organization" {
  type        = string
  description = "The organization name on terraform cloud"
  nullable    = false
}

variable "tfe_token" {
  description = "TFE Team token"
  nullable    = false
  default     = false
  sensitive   = true
}

variable "project" {
  type        = string
  nullable    = false
  description = "The name of the project that hosts the environment"
}

variable "service" {
  type        = string
  nullable    = false
  description = "The name of the service that will be run on the environment"
}

variable "db_connexion_string" {
  type        = string
  nullable    = false
  description = "A connexion string to the database associated with this api"
}

variable "third_party_api_keys" {
  type = map(object({
    key   = string
    value = string
  }))
  nullable    = false
  description = "Key-value pairs of third-party API keys"
  default     = {}
}

variable "private_subnets_ids" {
  type        = list(string)
  nullable    = false
  description = "The ids of the project vpc private subnets where the api is hosted"
}

variable "vpc_id" {
  type        = string
  nullable    = false
  description = "The id of the project vpc"
}

variable "cognito_authorizer_issuer" {
  type        = string
  nullable    = false
  description = "The cognito issuer that generated the token"
}

variable "cognito_authorizer_audience" {
  type        = list(string)
  nullable    = false
  description = "The cognito audience that is allowed to interact with the token"
}

variable "target_image" {
  type        = string
  nullable    = false
  description = "An image with a version tag has been released on the ECR repository"
}