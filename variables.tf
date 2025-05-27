variable "aws_region" {
  description = "The AWS region to deploy resources to"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources. Required tags: Environment, Owner, Project"
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      contains(keys(var.tags), "Environment"),
      contains(keys(var.tags), "Owner"),
      contains(keys(var.tags), "Project")
    ])
    error_message = "Tags must include Environment, Owner, and Project keys for compliance."
  }
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
}

variable "SDM_API_SECRET_KEY" {
  description = "The API secret key for the StrongDM API"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the gateway instance"
  type        = string
  default     = "t3.medium"
}

variable "SDM_ADMIN_TOKEN" {
  description = "The StrongDM admin token"
  type        = string
  sensitive   = false
}