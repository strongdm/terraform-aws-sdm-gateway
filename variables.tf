variable "aws_region" {
  description = "The AWS region to deploy resources to"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the gateway instance"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "The VPC ID where the gateway instance will be deployed"
  type        = string 
}