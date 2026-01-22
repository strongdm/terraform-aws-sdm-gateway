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
      type = "api"
      name = "test-github-account"
    }
  }
}

#------------------------------------------------------------------------------
# EC2 Instance Creation Tests
#------------------------------------------------------------------------------
run "validate_ec2_instance_created" {
  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.tags["Name"] == "sdm-gw-01"
    error_message = "EC2 instance should have correct Name tag"
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

run "validate_default_instance_type" {
  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.instance_type == "t3.medium"
    error_message = "Default instance type should be t3.medium"
  }
}

run "validate_custom_instance_type" {
  variables {
    aws_instance_type = "t3.large"
  }

  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.instance_type == "t3.large"
    error_message = "Instance type should be configurable"
  }
}

#------------------------------------------------------------------------------
# Security Configuration Tests
#------------------------------------------------------------------------------
run "validate_security_configurations" {
  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.root_block_device[0].encrypted == true
    error_message = "Root block device should be encrypted"
  }

  assert {
    condition     = aws_instance.gateway_ec2.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 should be required for security"
  }

  assert {
    condition     = aws_instance.gateway_ec2.metadata_options[0].http_endpoint == "enabled"
    error_message = "Metadata endpoint should be enabled"
  }
}

#------------------------------------------------------------------------------
# IAM Instance Profile Tests
#------------------------------------------------------------------------------
run "validate_with_iam_instance_profile" {
  variables {
    aws_iam_instance_profile = "test-profile"
  }

  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.iam_instance_profile == "test-profile"
    error_message = "IAM instance profile should be set when provided"
  }
}

#------------------------------------------------------------------------------
# Public IP Address Tests
#------------------------------------------------------------------------------
run "validate_public_ip_enabled_by_default" {
  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.associate_public_ip_address == true
    error_message = "Public IP should be enabled by default"
  }
}

run "validate_public_ip_can_be_disabled" {
  variables {
    associate_public_ip_address = false
  }

  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.associate_public_ip_address == false
    error_message = "Public IP should be disabled when associate_public_ip_address is false"
  }
}

#------------------------------------------------------------------------------
# AMI Configuration Tests
#------------------------------------------------------------------------------
run "validate_default_ami_from_data_source" {
  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.ami == "ami-mock12345"
    error_message = "AMI should use the data source lookup when ami_id is not specified"
  }
}

run "validate_custom_ami_id" {
  variables {
    ami_id = "ami-custom123"
  }

  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.ami == "ami-custom123"
    error_message = "AMI should use the custom ami_id when specified"
  }
}

run "validate_empty_ami_id_uses_data_source" {
  variables {
    ami_id = ""
  }

  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.ami == "ami-mock12345"
    error_message = "Empty ami_id should fall back to data source lookup"
  }
}

#------------------------------------------------------------------------------
# User Data Tests
#------------------------------------------------------------------------------
run "validate_user_data_is_base64_encoded" {
  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.user_data_base64 != null
    error_message = "User data should be base64 encoded"
  }

  assert {
    condition     = aws_instance.gateway_ec2.user_data_base64 != ""
    error_message = "User data should not be empty"
  }
}

#------------------------------------------------------------------------------
# Network Configuration Tests
#------------------------------------------------------------------------------
run "validate_subnet_assignment" {
  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.subnet_id == "subnet-12345678"
    error_message = "EC2 instance should be in the specified subnet"
  }
}

run "validate_security_group_assignment" {
  command = plan

  assert {
    condition     = contains(aws_instance.gateway_ec2.vpc_security_group_ids, "sg-1234567890")
    error_message = "EC2 instance should have the specified security group"
  }
}

#------------------------------------------------------------------------------
# Node Name Configuration Tests
#------------------------------------------------------------------------------
run "validate_custom_node_name" {
  variables {
    sdm_node_name = "custom-node-name"
  }

  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.user_data_base64 != null
    error_message = "User data should be set with custom node name"
  }
}

run "validate_use_instance_name_flag" {
  variables {
    sdm_use_instance_name = true
  }

  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.user_data_base64 != null
    error_message = "User data should be set when using instance name"
  }
}
