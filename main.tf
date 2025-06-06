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

# test bucket does not need to comply with tfsec rules
#tfsec:ignore:aws-s3-block-public-acls
#tfsec:ignore:aws-s3-block-public-policy  
#tfsec:ignore:aws-s3-enable-bucket-encryption
#tfsec:ignore:aws-s3-ignore-public-acls
#tfsec:ignore:aws-s3-no-public-buckets
#tfsec:ignore:aws-s3-encryption-customer-key
#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-specify-public-access-block
resource "aws_s3_bucket" "bucket" {
  bucket = "test-bucket-tf-generated"
  tags   = local.default_tags
}