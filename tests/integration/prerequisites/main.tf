variable "aws_region" {
  description = "The AWS region to deploy resources to"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

provider "aws" {
  region = var.aws_region
}
resource "aws_security_group" "sg" {
  name        = "sdm-gw-sg-sdm"
  description = "Security group for the StrongDM gateway"
  vpc_id      = var.vpc_id


  tags = merge(var.tags, {
    Name      = "sdm-gateway-sg"
    ManagedBy = "terraform"
  })
}


resource "aws_vpc_security_group_ingress_rule" "sdm_sg_ingress_rule" {
  security_group_id = aws_security_group.sg.id
  from_port         = 5000
  to_port           = 5000
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "sdm_sg_egress_rule" {
  security_group_id = aws_security_group.sg.id
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}


output "security_group_id" {
  description = "The ID of the created security group"
  value       = aws_security_group.sg.id
} 