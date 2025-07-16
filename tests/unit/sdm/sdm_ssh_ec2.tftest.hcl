variables {
  aws_region            = "us-east-1"
  aws_vpc_id            = "vpc-12345678"
  aws_subnet_id         = "subnet-12345678"
  aws_security_group_id = "sg-1234567890"
  aws_tags = {
    Environment = "test"
    Owner       = "terraform-test"
    Project     = "sdm-template"
  }
  SDM_API_ACCESS_KEY = "test-access-key"
  SDM_API_SECRET_KEY = "test-secret-key"
  SDM_ADMIN_TOKEN    = "admin_token_test"
  sdm_admin_token_secret_key  = "admin_token"
  sdm_admin_token_secret_name = "test-sdm-admin-token-secret"
  sdm_gateway_instance_name   = "sdm-gw-01"

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
      SDM_API_ACCESS_KEY = "test-access-key"
      SDM_API_SECRET_KEY = "test-secret-key"
    }
  }
}

run "validate_ec2_instance_created" {
  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.instance_type == "t3.medium"
    error_message = "EC2 instance should be created with correct instance type"
  }

  assert {
    condition     = aws_instance.gateway_ec2.tags["Name"] == "sdm-gw-01"
    error_message = "EC2 instance should have correct name tag"
  }

  assert {
    condition = alltrue([
      aws_instance.gateway_ec2.tags["Environment"] == "test",
      aws_instance.gateway_ec2.tags["Owner"] == "terraform-test",
      aws_instance.gateway_ec2.tags["Project"] == "sdm-template",
      aws_instance.gateway_ec2.tags["Application"] == "strongdm",
      aws_instance.gateway_ec2.tags["ManagedBy"] == "terraform"
    ])
    error_message = "EC2 instance should have the correct tags"
  }
}