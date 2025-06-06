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

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for detailed information about:

- **Commit Message Standards**: We use [Conventional Commits](https://www.conventionalcommits.org/) for consistent commit messages
- **Development Workflow**: Setup, testing, and submission process
- **Code Standards**: Terraform and Go formatting requirements

### Quick Start for Contributors

1. **Static Analysis**: `make all-static`
2. **Run Tests**: `go test -v ./tests`
3. **With direnv**: `direnv exec . go test -v ./tests`

### Quick References
- **[Contributing Guide](CONTRIBUTING.md)**: Complete development workflow and standards
- **[Commit Reference](docs/COMMIT_REFERENCE.md)**: Quick lookup for commit message format