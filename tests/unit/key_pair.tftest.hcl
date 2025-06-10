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



run "validate_ec2_has_key_pair" {
  command = apply

  assert {
    condition     = aws_instance.gateway_ec2.key_name == "tf-gw-key-pair"
    error_message = "EC2 instance should have a key pair"
  }
  assert {
    condition     = tls_private_key.sdm_gw_key_pair.public_key_openssh != null
    error_message = "Public key should be generated"
  }

  assert {
    condition     = can(tls_private_key.sdm_gw_key_pair.private_key_pem)
    error_message = "Private key PEM should be available in output"
  }

  assert {
    condition     = sensitive(tls_private_key.sdm_gw_key_pair.private_key_pem) != null
    error_message = "Private key should be sensitive"
  }

  assert {
    condition     = tls_private_key.sdm_gw_key_pair.algorithm == "RSA"
    error_message = "Key should use RSA algorithm"
  }
  
}