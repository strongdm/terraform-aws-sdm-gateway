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
      SDM_API_ACCESS_KEY = "test-access-key"
      SDM_API_SECRET_KEY = "test-secret-key"
    }
  }
}

run "validate_sdm_gateway_created" {
  command = apply

  assert {
    condition     = sdm_node.gw_ec2.id != null
    error_message = "SDM Gateway should be created"
  }

  assert {
    condition = alltrue([
      sdm_node.gw_ec2.gateway[0].listen_address != null,
      sdm_node.gw_ec2.gateway[0].bind_address != null,
    ])
    error_message = "SDM Gateway should have a listen address and bind address"
  }
}