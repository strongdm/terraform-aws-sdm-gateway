variable "aws_region" {
  description = "The AWS region to deploy resources to"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

variable "aws_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "SDM_ADMIN_TOKEN" {
  description = "The StrongDM admin token to store in secrets manager"
  type        = string
  sensitive   = true
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Generate a random suffix for unique resource names
resource "random_id" "test_id" {
  byte_length = 4
}
resource "aws_security_group" "sg" {
  name        = "sdm-gw-sg-sdm-gateway-${random_id.test_id.hex}"
  description = "Security group for the StrongDM gateway"
  vpc_id      = var.vpc_id


  tags = merge(var.aws_tags, {
    Name      = "sdm-gateway-sg-gateway"
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
  name                    = "sdm-admin-token-integration-test-gateway-${random_id.test_id.hex}"
  force_overwrite_replica_secret = true
  recovery_window_in_days = 0
  tags = merge(var.aws_tags, {
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
  name = "sdm-gateway-ssm-role-integration-test-gateway-${random_id.test_id.hex}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
  tags = merge(var.aws_tags, {
    Name      = "sdm-gateway-ssm-role-integration-test-gateway"
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
  name = "sdm-gateway-ssm-profile-integration-test-gateway-${random_id.test_id.hex}"
  role = aws_iam_role.ssm_role.name
  tags = merge(var.aws_tags, {
    Name      = "sdm-gateway-ssm-profile-integration-test-gateway"
    ManagedBy = "terraform"
  })
}

data "aws_caller_identity" "current" {}

# IAM role for GitHub Actions to assume during integration tests
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-integration-test-role-gateway-${random_id.test_id.hex}"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role_policy.json
  tags = merge(var.aws_tags, {
    Name      = "github-actions-integration-test-role-gateway"
    ManagedBy = "terraform"
  })
}

data "aws_iam_policy_document" "github_actions_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/anthony-github-action-user"]
    }
  }
}

# Comprehensive policy for GitHub Actions role
resource "aws_iam_role_policy" "github_actions_permissions" {
  name = "github-actions-integration-test-permissions-gateway-${random_id.test_id.hex}"
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "SecretsManagerPermissions",
        Effect = "Allow",
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets",
          "secretsmanager:PutSecretValue",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource",
          "secretsmanager:UpdateSecret"
        ],
        Resource = "*"
      },
      {
        Sid    = "EC2Permissions",
        Effect = "Allow",
        Action = [
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSecurityGroupRules",
          "ec2:DescribeSubnets",
          "ec2:DescribeTags",
          "ec2:DescribeVpcs",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RunInstances",
          "ec2:TerminateInstances"
        ],
        Resource = "*"
      },
      {
        Sid    = "IAMPermissions",
        Effect = "Allow",
        Action = [
          "iam:AttachRolePolicy",
          "iam:CreateInstanceProfile",
          "iam:CreateRole",
          "iam:DeleteInstanceProfile",
          "iam:DeleteRole",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          "iam:GetInstanceProfile",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:ListRolePolicies",
          "iam:PutRolePolicy",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:TagInstanceProfile",
          "iam:TagRole",
          "iam:UntagInstanceProfile",
          "iam:UntagRole"
        ],
        Resource = "*"
      },
      {
        Sid    = "PassRolePermissions",
        Effect = "Allow",
        Action = ["iam:PassRole"],
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sdm-gateway-ssm-role-integration-test-*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*integration-test*"
        ],
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ec2.amazonaws.com"
          }
        }
      },
      {
        Sid    = "STSPermissions",
        Effect = "Allow",
        Action = [
          "sts:GetCallerIdentity"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "allow_get_secret" {
  name = "allow-get-secret-integration-test-gateway-${random_id.test_id.hex}"
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

output "github_actions_role_arn" {
  description = "The ARN of the GitHub Actions role to assume"
  value       = aws_iam_role.github_actions_role.arn
} 