# StrongDM AWS Terraform Module Template

This template provides a foundation for creating AWS-based StrongDM deployments using Terraform.

## Standards & Requirements

### Tagging Standards
All resources should include these tags:
- `Environment`: Production, Staging, Development, etc.
- `Owner`: Team or individual responsible for the resource
- `Project`: Project or application name

Additional standard tags are automatically applied:
- `Name`: Resource identifier
- `ManagedBy`: "terraform"
- `Application`: "strongdm"


## Features
- AWS-specific resource provisioning for StrongDM gateways
- Standardized module structure for consistency
- Enforced tagging

## Usage
```hcl
module "strongdm_aws" {
  source = "path/to/terraform-aws-template"
  
  // Required parameters
  aws_region = "us-west-2"
  name       = "aws-production-gateway"
  vpc_id     = "vpc-xxxxxxxx"
  subnet_id  = "subnet-xxxxxxxx"
  
  // Required: Compliance tags
  tags = {
    Environment = "Production"
    Owner       = "platform-team"
    Project     = "strongdm-infrastructure"
  }
}
```

## Requirements
- Terraform >= 1
- AWS provider >= 4.0
- Valid StrongDM API credentials
- Valid AWS credentials

## Inputs, Outputs, and Resources
See the respective documentation files for details.

## How to Contribute
Check out the Makefile and github actions for detailed steps on what checks are required for your commit to pass.

To quickly check all static analysis run
`make all-static`