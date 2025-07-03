variable "aws_region" {
  description = "The AWS region to deploy resources to"
  type        = string
}

variable "tags" {
  description = "Optional tags to apply to all resources. These will be merged with automatic tags (ManagedBy, Application, Name)"
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

variable "instance_type" {
  description = "The instance type for the gateway instance"
  type        = string
  default     = "t3.medium"
}

variable "gateway_instance_name" {
  description = "The  name of the gateway instance"
  type        = string
  default     = "sdm-gw-01"
}

variable "SDM_ADMIN_TOKEN" {
  description = "The StrongDM admin token"
  type        = string
  sensitive   = true
  default     = ""
}

variable "aws_security_group_id" {
  description = "Security group for the SDM gateways"
  type        = string
}

variable "sdm_admin_token_secret_name" {
  description = "The name of the AWS Secrets Manager secret to store the SDM admin token."
  type        = string
  default     = "sdm_admin_token"
}

variable "sdm_admin_token_secret_key" {
  description = "The key name in the AWS Secrets Manager secret for the SDM admin token."
  type        = string
  default     = "admin_token"
}

variable "iam_instance_profile" {
  description = "The name of the IAM instance profile to attach to the EC2 instance."
  type        = string
  default     = ""
}