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
  SDM_API_ACCESS_KEY          = "test-access-key"
  SDM_API_SECRET_KEY          = "test-secret-key"
  SDM_ADMIN_TOKEN             = "admin_token_test"
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

  mock_data "aws_ami" {
    defaults = {
      id = "ami-mock12345"
    }
  }

  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-east-1a", "us-east-1b", "us-east-1c"]
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

#------------------------------------------------------------------------------
# Basic EC2 Instance Tests
#------------------------------------------------------------------------------
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

#------------------------------------------------------------------------------
# SDM Configuration Tests
#------------------------------------------------------------------------------
run "validate_sdm_app_domain_default" {
  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.user_data_base64 != null
    error_message = "User data should be set with default SDM app domain"
  }
}

run "validate_custom_sdm_app_domain" {
  variables {
    sdm_app_domain = "custom.strongdm.com"
  }

  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.user_data_base64 != null
    error_message = "User data should be set with custom SDM app domain"
  }
}

#------------------------------------------------------------------------------
# Private Gateway Tests
#------------------------------------------------------------------------------
run "validate_private_gateway_config" {
  variables {
    associate_public_ip_address = false
  }

  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.associate_public_ip_address == false
    error_message = "Private gateway should not have public IP"
  }

  assert {
    condition     = aws_instance.gateway_ec2.subnet_id == "subnet-12345678"
    error_message = "Private gateway should be in specified subnet"
  }
}

#------------------------------------------------------------------------------
# Output Tests
#------------------------------------------------------------------------------
run "validate_outputs_exist" {
  command = plan

  assert {
    condition     = output.vpc_id != null
    error_message = "VPC ID output should exist"
  }

  assert {
    condition     = output.subnet_id != null
    error_message = "Subnet ID output should exist"
  }

  assert {
    condition     = output.gateway_instance_name != null
    error_message = "Gateway instance name output should exist"
  }
}
