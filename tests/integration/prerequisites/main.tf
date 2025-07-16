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

variable "SDM_ADMIN_TOKEN" {
  description = "The StrongDM admin token to store in secrets manager"
  type        = string
  sensitive   = true
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

# AWS Secrets Manager secret for SDM admin token
resource "aws_secretsmanager_secret" "sdm_admin_token" {
  name                    = "sdm-admin-token-integration-test"
  force_overwrite_replica_secret = true
  recovery_window_in_days = 0
  tags = merge(var.tags, {
    Name      = "sdm-admin-token-integration-test"
    ManagedBy = "terraform"
  })
}

resource "aws_secretsmanager_secret_version" "sdm_admin_token_version" {
  secret_id     = aws_secretsmanager_secret.sdm_admin_token.id
  secret_string = jsonencode({
    admin_token = var.SDM_ADMIN_TOKEN
  })
}

# IAM role for EC2 instance
resource "aws_iam_role" "ssm_role" {
  name = "sdm-gateway-ssm-role-integration-test"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
  tags = merge(var.tags, {
    Name      = "sdm-gateway-ssm-role-integration-test"
    ManagedBy = "terraform"
  })
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "sdm-gateway-ssm-profile-integration-test"
  role = aws_iam_role.ssm_role.name
  tags = merge(var.tags, {
    Name      = "sdm-gateway-ssm-profile-integration-test"
    ManagedBy = "terraform"
  })
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "allow_get_secret" {
  name = "allow-get-secret-integration-test"
  role = aws_iam_role.ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${aws_secretsmanager_secret.sdm_admin_token.name}*"
      }
    ]
  })
}

output "security_group_id" {
  description = "The ID of the created security group"
  value       = aws_security_group.sg.id
}

output "secret_name" {
  description = "The name of the secrets manager secret"
  value       = aws_secretsmanager_secret.sdm_admin_token.name
}

output "iam_instance_profile_name" {
  description = "The name of the IAM instance profile"
  value       = aws_iam_instance_profile.ssm_profile.name
}

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = aws_iam_role.ssm_role.name
} 