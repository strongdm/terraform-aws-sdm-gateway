variables {
  aws_region = "us-east-1"
  vpc_id     = "vpc-12345678"
  subnet_id  = "subnet-12345678"
  tags = {
    Environment = "test"
    Owner       = "terraform-test"
    Project     = "sdm-template"
  }
  SDM_API_ACCESS_KEY = "test-access-key"
  SDM_API_SECRET_KEY = "test-secret-key"
}

mock_provider "aws" {
  mock_data "aws_vpc" {
    defaults = {
      id = "vpc-12345678"
    }
  }
  
  mock_data "aws_subnet" {
    defaults = {
      id = "subnet-12345678"
    }
  }
}

mock_provider "sdm" {
  mock_data "sdm_account" {
    defaults = {
      type = "api"
      name = "test-github-account"
    }
  }
}

run "validate_s3_test_bucket_created" {
  command = plan

  assert {
    condition     = aws_s3_bucket.bucket.bucket == "test-bucket-tf-generated"
    error_message = "S3 bucket should be created"
  }
  
  assert {
    condition = alltrue([
      aws_s3_bucket.bucket.tags["Environment"] == "test",
      aws_s3_bucket.bucket.tags["Owner"] == "terraform-test",
      aws_s3_bucket.bucket.tags["Project"] == "sdm-template",
      aws_s3_bucket.bucket.tags["Application"] == "strongdm",
      aws_s3_bucket.bucket.tags["ManagedBy"] == "terraform"
    ])
    error_message = "S3 bucket must have all required tags with correct values"
  }
}