variables {
  aws_region            = "us-east-1"
  vpc_id                = "vpc-12345678"
  subnet_id             = "subnet-12345678"
  aws_security_group_id = "sg-1234567890"
  tags = {
    Environment = "test"
    Owner       = "terraform-test"
    Project     = "sdm-template"
  }
  SDM_API_ACCESS_KEY = "test-access-key"
  SDM_API_SECRET_KEY = "test-secret-key"
  SDM_ADMIN_TOKEN    = "admin_token_test"

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


run "validate_ec2_instance_created" {
  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.tags["Name"] == "sdm-gw-01"
    error_message = "EC2 instance should be created"
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

run "validate_ec2_instance_public_ip" {
  command = apply

  assert {
    condition     = aws_instance.gateway_ec2.public_ip != null
    error_message = "EC2 instance public ip output should exist"
  }
}


run "user_data_contains_admin_token_variable" {
  command = plan

  assert {
    condition     = can(regex(".*admin_token_test.*", base64decode(aws_instance.gateway_ec2.user_data)))
    error_message = "User data should contain the admin token"
  }

}