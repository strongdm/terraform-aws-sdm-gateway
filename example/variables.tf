variable "aws_region" {
  description = "The AWS region to deploy resources to"
  type        = string
}

variable "gateway_instance_name_1" {
  description = "The gateway instance name"
  type        = string
}

variable "gateway_instance_name_2" {
  description = "The second gateway instance name"
  type        = string
}

variable "SDM_ADMIN_TOKEN" {
  description = "The StrongDM admin token"
  type        = string
  sensitive   = true
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

variable "sdm_node_name" {
  description = "The StrongDM node name to register the gateway with"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "The subnet ID where the gateway instance will be deployed"
  type        = string
}

variable "aws_tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The VPC ID where the gateway instance will be deployed"
  type        = string
}