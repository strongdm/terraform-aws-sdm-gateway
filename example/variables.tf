variable "aws_region" {
  description = "The AWS region to deploy resources to"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The VPC ID where the gateway instance will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID where the gateway instance will be deployed"
  type        = string
}

variable "SDM_API_ACCESS_KEY" {
  description = "The API access key for the StrongDM API"
  type        = string
  sensitive   = true
}

variable "SDM_API_SECRET_KEY" {
  description = "The API secret key for the StrongDM API"
  type        = string
  sensitive   = true
}

variable "SDM_ADMIN_TOKEN" {
  description = "The StrongDM admin token"
  type        = string
  sensitive   = true
}

variable "gateway_instance_name_1" {
  description = "The gateway instance name"
  type        = string
}

variable "gateway_instance_name_2" {
  description = "The second gateway instance name"
  type        = string
}