provider "aws" {
  region = var.aws_region
}

locals {
  default_tags = merge(
    var.aws_tags,
    {
      ManagedBy   = "terraform"
      Application = "strongdm"
    }
  )
  user_data = templatefile("${path.module}/scripts/user_data.sh", {
    ADMIN_TOKEN_SECRET_NAME = var.sdm_admin_token_secret_name,
    AWS_REGION = var.aws_region,
    ADMIN_TOKEN_SECRET_KEY = var.sdm_admin_token_secret_key,
    SDM_APP_DOMAIN = var.sdm_app_domain,
    SDM_NODE_NAME = var.sdm_node_name,
    SDM_USE_INSTANCE_NAME = var.sdm_use_instance_name
  })
}

data "aws_vpc" "vpc" {
  id = var.aws_vpc_id
}

data "aws_subnet" "subnet" {
  id = var.aws_subnet_id
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
  instance_type          = var.aws_instance_type
  subnet_id              = data.aws_subnet.subnet.id
  vpc_security_group_ids = [var.aws_security_group_id]
  user_data              = base64encode(local.user_data)
  tags = merge(local.default_tags, {
    Name = var.sdm_gateway_instance_name
  })

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    encrypted = true
  }

  iam_instance_profile = var.aws_iam_instance_profile != "" ? var.aws_iam_instance_profile : null
}

