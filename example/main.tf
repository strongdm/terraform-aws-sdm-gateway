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

resource "aws_vpc_security_group_egress_rule" "sdm_sg_egress_rule" {
  security_group_id = aws_security_group.sg.id
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}


module "sdm_gateway_1" {
  # source                = "git::https://github.com/strongdm/terraform-aws-sdm-gateway.git"
  source                = "../"
  aws_region            = var.aws_region
  vpc_id                = var.vpc_id
  subnet_id             = var.subnet_id
  SDM_API_ACCESS_KEY    = var.SDM_API_ACCESS_KEY
  SDM_API_SECRET_KEY    = var.SDM_API_SECRET_KEY
  SDM_ADMIN_TOKEN       = var.SDM_ADMIN_TOKEN
  tags                  = var.tags
  gateway_instance_name = var.gateway_instance_name_1
  aws_security_group_id = aws_security_group.sg.id
}


module "sdm_gateway_2" {
  # source                = "git::https://github.com/strongdm/terraform-aws-sdm-gateway.git"
  source                = "../"
  aws_region            = var.aws_region
  vpc_id                = var.vpc_id
  subnet_id             = var.subnet_id
  SDM_API_ACCESS_KEY    = var.SDM_API_ACCESS_KEY
  SDM_API_SECRET_KEY    = var.SDM_API_SECRET_KEY
  SDM_ADMIN_TOKEN       = var.SDM_ADMIN_TOKEN
  tags                  = var.tags
  gateway_instance_name = var.gateway_instance_name_2
  aws_security_group_id = aws_security_group.sg.id
}