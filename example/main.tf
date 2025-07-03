provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "sg" {
  name        = "sdm-gw-sg-sdm"
  description = "Security group for the StrongDM gateway"
  vpc_id      = var.vpc_id
  tags        = var.tags
}


resource "aws_vpc_security_group_ingress_rule" "sdm_sg_ingress_rule" {
  security_group_id = aws_security_group.sg.id
  from_port         = 5000
  to_port           = 5000
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "https_ingress" {
  security_group_id = aws_security_group.sg.id
  from_port         = 443
  to_port           = 443
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

resource "aws_secretsmanager_secret" "sdm_admin_token" {
  name = var.sdm_admin_token_secret_name
}

resource "aws_secretsmanager_secret_version" "sdm_admin_token_version" {
  secret_id     = aws_secretsmanager_secret.sdm_admin_token.id
  secret_string = jsonencode({
    admin_token = var.SDM_ADMIN_TOKEN
  })
}

resource "aws_iam_role" "ssm_role" {
  name = "sdm-gateway-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
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
  name = "sdm-gateway-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnet_id]
  security_group_ids  = [aws_security_group.sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnet_id]
  security_group_ids  = [aws_security_group.sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnet_id]
  security_group_ids  = [aws_security_group.sg.id]
  private_dns_enabled = true
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "allow_get_secret" {
  name = "allow-get-secret"
  role = aws_iam_role.ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.sdm_admin_token_secret_name}*"
      }
    ]
  })
}



module "sdm_gateway_1" {
  # source                = "git::https://github.com/strongdm/terraform-aws-sdm-gateway.git"
  source                      = "../"
  aws_region                  = var.aws_region
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  sdm_admin_token_secret_name = aws_secretsmanager_secret.sdm_admin_token.name
  tags                        = var.tags
  gateway_instance_name       = var.gateway_instance_name_1
  aws_security_group_id       = aws_security_group.sg.id
  sdm_admin_token_secret_key  = var.sdm_admin_token_secret_key
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
}


module "sdm_gateway_2" {
  # source                = "git::https://github.com/strongdm/terraform-aws-sdm-gateway.git"
  source                      = "../"
  aws_region                  = var.aws_region
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  sdm_admin_token_secret_name = aws_secretsmanager_secret.sdm_admin_token.name
  tags                        = var.tags
  gateway_instance_name       = var.gateway_instance_name_2
  aws_security_group_id       = aws_security_group.sg.id
  sdm_admin_token_secret_key  = var.sdm_admin_token_secret_key
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
}