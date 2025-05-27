provider "aws" {
  region = var.aws_region
}

provider "sdm" {
  api_access_key = var.SDM_API_ACCESS_KEY
  api_secret_key = var.SDM_API_SECRET_KEY
}

provider "tls" {
}

locals {
  default_tags = merge(
    var.tags,
    {
      ManagedBy   = "terraform"
      Application = "strongdm"
    }
  )
  user_data = templatefile("${path.module}/user_data.sh", {
    ADMIN_TOKEN = var.SDM_ADMIN_TOKEN
  })
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_subnet" "subnet" {
  id = var.subnet_id
}

data "sdm_account" "api-key-queries" {
  type = "api"
  name = "*github*"
}

data "aws_ami" "latest_gateway" {
  most_recent = true

  owners = ["522179138863"] # StrongDM's account ID

  filter {
    name   = "name"
    values = ["strongdm/gateway/*"]
  }

}

resource "aws_instance" "gateway_ec2" {
  ami                    = data.aws_ami.latest_gateway.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data = base64encode(local.user_data)
  tags = merge(local.default_tags, {
    Name = "sdm-gw-01"
  })

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    encrypted = true
  }
}

resource "aws_security_group" "sg" {
  name        = "sdm-gw-sg-sdm"
  description = "Security group for the StrongDM gateway"
  vpc_id      = data.aws_vpc.vpc.id


  tags = local.default_tags
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
