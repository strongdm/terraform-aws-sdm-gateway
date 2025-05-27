# StrongDM AWS Terraform Module Template

This template provides a foundation for creating AWS-based StrongDM deployments using Terraform.

## Features
- AWS-specific resource provisioning for StrongDM gateways
- Standardized module structure for consistency

## Usage
```hcl
module "strongdm_aws" {
  source = "path/to/terraform-aws-template"
  
  // Required parameters
  aws_region     = "us-west-2"
  gateway_name   = "aws-production-gateway"
  
  // Optional parameters with defaults
  instance_type  = "t3.medium"
  vpc_id         = "vpc-xxxxxxxx"
  // Additional parameters...
}
```

## Requirements
- Terraform >= 1
- AWS provider >= 4.0
- Valid StrongDM API credentials
- Valid AWS credentials

## Inputs, Outputs, and Resources
See the respective documentation files for details.
