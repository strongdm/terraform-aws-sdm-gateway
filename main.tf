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

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_subnet" "subnet" {
  id = var.subnet_id
}