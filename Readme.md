# StrongDM AWS Terraform Module Template

This template provides a foundation for creating AWS-based StrongDM deployments using Terraform.

## Standards & Requirements

### Tagging Standards
You can optionally provide tags to be applied to all resources. The module automatically adds these standard tags:
- `ManagedBy`: "terraform"
- `Application`: "strongdm"
- `Name`: Resource identifier (from gateway_instance_name)

To add your own tags, use the `tags` variable:

```hcl
module "strongdm_aws" {
  source = "strongdm/sdm-gateway"
  
  // Required parameters
  aws_region = "us-west-2"
  name       = "aws-production-gateway"
  vpc_id     = "vpc-xxxxxxxx"
  subnet_id  = "subnet-xxxxxxxx"
  
  // Optional: Custom tags
  tags = {
    Environment = "Production"
    Owner       = "platform-team"
    Project     = "strongdm-infrastructure"
    CostCenter  = "IT-123"
  }
}
```

## Features
- AWS-specific resource provisioning for StrongDM gateways
- Standardized module structure for consistency
- Automatic tagging with standard metadata
- Support for custom tags

## Usage
```hcl
module "strongdm_aws" {
  source = "strongdm/sdm-gateway"
  
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

## Example Deployment

A complete example deployment is provided in the [`example/`](./example/) directory. This includes:
- Example `main.tf` showing how to use the module with two gateway instances
- Example `variables.tf` and `terraform.tfvars.example` for required variables
- Example `outputs.tf` to expose useful outputs

To try the example:
1. Copy `example/terraform.tfvars.example` to `example/terraform.tfvars` and fill in your values.
2. Run `terraform init` and `terraform apply` inside the `example/` directory.

Refer to the files in `example/` for a practical usage reference.

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for detailed information about:

- **Commit Message Standards**: We use [Conventional Commits](https://www.conventionalcommits.org/) for consistent commit messages
- **Development Workflow**: Setup, testing, and submission process
- **Code Standards**: Terraform and Go formatting requirements

### Quick Start for Contributors

1. **Static Analysis**: `make all-static`
2. **Run Integration Tests**: `go test -v ./tests/integration`
3. **With direnv**: `direnv exec . go test -v ./tests/integration`
4. **Terraform test (unit tests)**terraform test -test-directory ./tests/unit`

### Quick References
- **[Contributing Guide](CONTRIBUTING.md)**: Complete development workflow and standards
- **[Commit Reference](docs/COMMIT_REFERENCE.md)**: Quick lookup for commit message format