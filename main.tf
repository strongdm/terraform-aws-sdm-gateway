provider "aws" {
  region = var.aws_region
}

provider "sdm" {
  api_access_key = var.SDM_API_ACCESS_KEY
  api_secret_key = var.SDM_API_SECRET_KEY
}

locals {
  default_tags = merge(
    var.tags,
    {
      ManagedBy   = "terraform"
      Application = "strongdm"
    }
  )
  user_data = templatefile("${path.module}/scripts/user_data.sh", {
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
  vpc_security_group_ids = [var.aws_security_group_id]
  user_data              = base64encode(local.user_data)
  tags = merge(local.default_tags, {
    Name = var.gateway_instance_name
  })

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    encrypted = true
  }
}


