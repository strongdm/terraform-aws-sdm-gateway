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


run "user_data_contains_secret_manager_variables" {
  command = plan

  assert {
    condition     = can(regex(".*test-sdm-admin-token-secret.*", base64decode(aws_instance.gateway_ec2.user_data)))
    error_message = "User data should contain the secret name for fetching admin token from Secrets Manager"
  }

  assert {
    condition     = can(regex(".*admin_token.*", base64decode(aws_instance.gateway_ec2.user_data)))
    error_message = "User data should contain the secret key for fetching admin token from Secrets Manager"
  }

}

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

run "validate_user_data_script_content" {
  command = plan

  assert {
    condition     = can(regex(".*aws secretsmanager get-secret-value.*", base64decode(aws_instance.gateway_ec2.user_data)))
    error_message = "User data should contain AWS Secrets Manager CLI command"
  }

  assert {
    condition     = can(regex(".*systemctl restart sdm-relay-setup.*", base64decode(aws_instance.gateway_ec2.user_data)))
    error_message = "User data should restart SDM relay setup service"
  }

  assert {
    condition     = can(regex(".*systemctl enable sdm-proxy.*", base64decode(aws_instance.gateway_ec2.user_data)))
    error_message = "User data should enable SDM proxy service"
  }
}

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

run "validate_default_instance_type" {
  command = plan

  assert {
    condition     = aws_instance.gateway_ec2.instance_type == "t3.medium"
    error_message = "Default instance type should be t3.medium"
  }
}