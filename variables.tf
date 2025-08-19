variable "aws_iam_instance_profile" {
  description = "The name of the IAM instance profile to attach to the EC2 instance."
  type        = string
  default     = ""
}

variable "aws_instance_type" {
  description = "The instance type for the gateway instance"
  type        = string
  default     = "t3.medium"
}

variable "aws_region" {
  description = "The AWS region to deploy resources to"
  type        = string
}

variable "aws_security_group_id" {
  description = "Security group for the SDM gateways"
  type        = string
}

variable "aws_subnet_id" {
  description = "The subnet ID where the gateway instance will be deployed"
  type        = string
}

variable "aws_tags" {
  description = "Optional tags to apply to all resources. These will be merged with automatic tags (ManagedBy, Application, Name)"
  type        = map(string)
  default     = {}
}

variable "aws_vpc_id" {
  description = "The VPC ID where the gateway instance will be deployed"
  type        = string
}

variable "sdm_admin_token_secret_key" {
  description = "The key name in the AWS Secrets Manager secret for the SDM admin token."
  type        = string
}

variable "sdm_admin_token_secret_name" {
  description = "The name of the AWS Secrets Manager secret to store the SDM admin token."
  type        = string
}

variable "sdm_app_domain" {
  description = "The StrongDM control plane domain the gateway connects to"
  type        = string
  default     = "app.strongdm.com"
}

variable "sdm_gateway_instance_name" {
  description = "The name of the gateway instance"
  type        = string
  default     = ""
}

variable "sdm_node_name" {
  description = "The StrongDM node name to register the gateway with"
  type        = string
  default     = ""
}

variable "sdm_use_instance_name" {
  description = "Use the instance name as the StrongDM node name"
  type        = bool
  default     = false
}
