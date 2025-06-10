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



run "validate_ec2_security_group_created" {
  command = plan

  assert {
    condition     = aws_security_group.sg.name == "sdm-gw-sg-sdm"
    error_message = "Security group should be created"
  }

  assert {
    condition = alltrue([
      aws_vpc_security_group_ingress_rule.sdm_sg_ingress_rule.from_port == 5000,
      aws_vpc_security_group_ingress_rule.sdm_sg_ingress_rule.to_port == 5000,
      aws_vpc_security_group_ingress_rule.sdm_sg_ingress_rule.ip_protocol == "tcp",
      aws_vpc_security_group_ingress_rule.sdm_sg_ingress_rule.cidr_ipv4 == "0.0.0.0/0",
    ])
    error_message = "Security group rules exists with correct rules"
  }

  assert {
    condition = alltrue([
      aws_security_group.sg.tags["Environment"] == "test",
      aws_security_group.sg.tags["Owner"] == "terraform-test",
      aws_security_group.sg.tags["Project"] == "sdm-template",
      aws_security_group.sg.tags["Application"] == "strongdm",
      aws_security_group.sg.tags["ManagedBy"] == "terraform"
    ])
    error_message = "Security group exists with correct tags"
  }

  
}