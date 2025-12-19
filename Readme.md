# StrongDM AWS Terraform Module

This module deploys StrongDM gateway instances on AWS EC2.

## Features

- AWS EC2 instance provisioning for StrongDM gateways
- Support for public and private subnet deployments
- Custom AMI support with automatic latest AMI lookup fallback
- Automatic tagging with standard metadata
- IMDSv2 enforcement and encrypted root volumes
- Flexible node naming options

## Usage

### Basic Usage (Public Gateway)

```hcl
module "sdm_gateway" {
  source = "git::https://github.com/strongdm/terraform-aws-sdm-gateway.git"

  aws_region                  = "us-west-2"
  aws_vpc_id                  = "vpc-xxxxxxxx"
  aws_subnet_id               = "subnet-xxxxxxxx"
  aws_security_group_id       = "sg-xxxxxxxx"
  sdm_admin_token_secret_name = "sdm-admin-token"
  sdm_admin_token_secret_key  = "admin_token"
  sdm_gateway_instance_name   = "sdm-gateway-prod"
  sdm_node_name               = "sdm-gateway-prod"

  aws_tags = {
    Environment = "Production"
    Owner       = "platform-team"
  }
}
```

### Private Gateway (No Public IP)

For deployments in private subnets without internet-facing IP addresses:

```hcl
module "sdm_gateway_private" {
  source = "git::https://github.com/strongdm/terraform-aws-sdm-gateway.git"

  aws_region                  = "us-west-2"
  aws_vpc_id                  = "vpc-xxxxxxxx"
  aws_subnet_id               = "subnet-private-xxxxxxxx"
  aws_security_group_id       = "sg-xxxxxxxx"
  sdm_admin_token_secret_name = "sdm-admin-token"
  sdm_admin_token_secret_key  = "admin_token"
  sdm_gateway_instance_name   = "sdm-gateway-private"
  sdm_node_name               = "sdm-gateway-private"

  associate_public_ip_address = false

  aws_tags = {
    Environment = "Production"
    Owner       = "platform-team"
  }
}
```

Note: Private gateways require outbound internet connectivity via NAT Gateway to reach the StrongDM control plane.

### Custom AMI

To use a specific AMI instead of the latest StrongDM gateway AMI:

```hcl
module "sdm_gateway" {
  source = "git::https://github.com/strongdm/terraform-aws-sdm-gateway.git"

  ami_id = "ami-0123456789abcdef0"

  # ... other required variables
}
```

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.0 |
| AWS Provider | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | The AWS region to deploy resources to | `string` | n/a | yes |
| aws_vpc_id | The VPC ID where the gateway instance will be deployed | `string` | n/a | yes |
| aws_subnet_id | The subnet ID where the gateway instance will be deployed | `string` | n/a | yes |
| aws_security_group_id | Security group for the SDM gateway | `string` | n/a | yes |
| sdm_admin_token_secret_name | The name of the AWS Secrets Manager secret containing the SDM admin token | `string` | n/a | yes |
| sdm_admin_token_secret_key | The key name in the AWS Secrets Manager secret for the SDM admin token | `string` | n/a | yes |
| ami_id | Optional AMI ID to use. If not specified, uses the latest StrongDM gateway AMI | `string` | `""` | no |
| associate_public_ip_address | Whether to associate a public IP address with the gateway instance | `bool` | `true` | no |
| aws_iam_instance_profile | The name of the IAM instance profile to attach to the EC2 instance | `string` | `""` | no |
| aws_instance_type | The instance type for the gateway instance | `string` | `"t3.medium"` | no |
| aws_tags | Optional tags to apply to all resources | `map(string)` | `{}` | no |
| sdm_app_domain | The StrongDM control plane domain the gateway connects to | `string` | `"app.strongdm.com"` | no |
| sdm_gateway_instance_name | The name of the gateway instance | `string` | `""` | no |
| sdm_node_name | The StrongDM node name to register the gateway with | `string` | `""` | no |
| sdm_use_instance_name | Use the instance name as the StrongDM node name | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | VPC ID |
| subnet_id | Subnet ID |
| default_tags | Standard tags applied to all resources |
| ec2_instance_public_ip | EC2 instance public IP |
| ec2_instance_public_dns | EC2 instance public DNS |
| gateway_instance_name | Name of the StrongDM gateway instance |

## Tagging Standards

The module automatically adds these standard tags to all resources:
- `ManagedBy`: "terraform"
- `Application`: "strongdm"
- `Name`: Resource identifier (from gateway_instance_name)

Custom tags can be added via the `aws_tags` variable and will be merged with the standard tags.

## Example Deployment

A complete self-contained example is provided in the [`example/`](./example/) directory. This includes:

- Full VPC infrastructure (VPC, subnets, Internet Gateway, NAT Gateway, route tables)
- Security groups and IAM roles
- VPC endpoints for AWS services (SSM, Secrets Manager)
- Four gateway deployment examples:
  1. Public gateway with custom node name
  2. Public gateway using instance name as node name
  3. Public gateway with auto-generated node name
  4. Private gateway without public IP (uses NAT Gateway)

To try the example:

1. Copy `example/terraform.tfvars.example` to `example/terraform.tfvars` and fill in your values
2. Run `terraform init` inside the `example/` directory
3. Run `terraform apply`

## Security Features

- IMDSv2 is required (http_tokens = "required")
- Root block device encryption is enabled by default
- Metadata endpoint is enabled for instance configuration

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for detailed information about:

- Commit Message Standards: We use [Conventional Commits](https://www.conventionalcommits.org/)
- Development Workflow: Setup, testing, and submission process
- Code Standards: Terraform and Go formatting requirements

### Running Tests

```bash
# Run all static analysis (fmt, lint, validate)
make all-static

# Run unit tests
make unit-test

# Run integration tests
make integration-test

# Run all tests (unit + integration)
make test
```

Individual commands:

```bash
# Format code
make fmt

# Lint with tfsec and tflint
make lint

# Validate terraform
make validate

# Install required tools (macOS)
make bootstrap
```

### Quick References

- [Contributing Guide](CONTRIBUTING.md): Complete development workflow and standards
- [Commit Reference](docs/COMMIT_REFERENCE.md): Quick lookup for commit message format
