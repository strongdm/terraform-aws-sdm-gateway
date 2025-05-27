provider "aws" {
  region = var.aws_region
}

provider "strongdm" {}

locals {
  default_tags = merge(
    var.tags,
    {
      Name        = var.name
      ManagedBy   = "terraform"
      Application = "strongdm"
    }
  )
}

resource "aws_instance" "gateway" {
  ami           = "ami-04999cd8f2624f834"
  instance_type = "t3.medium"
  subnet_id     = var.vpc_id
  vpc_security_group_ids = var.security_group_ids
  tags = local.default_tags
}