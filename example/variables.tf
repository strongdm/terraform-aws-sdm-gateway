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

variable "aws_tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "ami_id" {
  description = "Optional AMI ID to use for the gateway instances. If not specified, the latest StrongDM gateway AMI will be used."
  type        = string
  default     = ""
}