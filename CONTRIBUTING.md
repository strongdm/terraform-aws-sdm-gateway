# Contributing Guide

Thank you for contributing to the StrongDM AWS Terraform Module Template! This guide outlines the standards and processes for contributing to this project.

## Commit Message Convention

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification to ensure consistent and meaningful commit messages.

### Format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types
- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **perf**: A code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **chore**: Changes to the build process or auxiliary tools and libraries

### Examples
```bash
# Previous style → New style
.r Formatting → style: format code according to standards
@b Removed unneeded assertion → fix: remove unnecessary test assertion
@b Remove test from static analysis → fix(test): exclude flaky test from static analysis
^f Test with sdm provider → feat(test): add integration test with SDM provider
```

### Migration from Current Convention
If you're used to our previous shorthand notation:
- `.r` (refactor/format) → `style:` or `refactor:`
- `@b` (bugfix) → `fix:`
- `^f` (feature) → `feat:`

## Development Workflow

### Prerequisites
- Terraform >= 1.0
- Go >= 1.21
- AWS CLI configured
- StrongDM API credentials

### Setup
1. Clone the repository
2. Install dependencies: `go mod download`
3. Set up environment variables (see `.env.example` if available)
4. Configure git commit template (optional but recommended):
   ```bash
   git config commit.template .gitmessage
   ```

### Before Committing

#### Static Analysis
Run all static analysis checks:
```bash
make all-static
```

#### Testing
Run the full test suite:
```bash
# Standard run
go test -v ./test

# With direnv (if using environment variable injection)
direnv exec . go test -v ./test
```

### Pull Request Process

1. **Branch naming**: Use descriptive names like `feat/add-security-groups` or `fix/vpc-configuration`

2. **Commit messages**: Follow the conventional commit format outlined above

3. **Testing**: Ensure all tests pass and static analysis is clean

4. **Documentation**: Update relevant documentation if your changes affect usage

5. **Review**: Submit your PR and address any feedback from reviewers

### Code Standards

#### Terraform
- Follow HashiCorp's [Terraform Style Guide](https://developer.hashicorp.com/terraform/language/style)
- Use meaningful variable and resource names
- Include proper descriptions for all variables
- Tag all resources appropriately

#### Go (Tests)
- Follow standard Go formatting (`go fmt`)
- Write descriptive test names
- Include proper error handling
- Use table-driven tests when appropriate

#### Required Tags
All AWS resources must include these tags:
- `Environment`: Production, Staging, Development, etc.
- `Owner`: Team or individual responsible
- `Project`: Project or application name

## Getting Help

- Check existing issues before creating new ones
- Use descriptive titles and provide context
- Include relevant logs, configurations, and error messages
- Tag issues appropriately (`bug`, `enhancement`, `question`, etc.)

## License

By contributing, you agree that your contributions will be licensed under the same license as this project.
