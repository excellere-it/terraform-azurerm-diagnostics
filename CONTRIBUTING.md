# Contributing to terraform-azurerm-diagnostics

Thank you for your interest in contributing to the terraform-azurerm-diagnostics module! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation Standards](#documentation-standards)
- [Questions and Support](#questions-and-support)

## Code of Conduct

This project adheres to a code of conduct that all contributors are expected to follow. Be respectful, inclusive, and constructive in all interactions.

### Our Standards

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) >= 1.3
- [terraform-docs](https://github.com/terraform-docs/terraform-docs) (for documentation generation)
- [Make](https://www.gnu.org/software/make/) (optional, but recommended)
- Azure CLI (for testing deployments)

### Setting Up Your Development Environment

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/terraform-azurerm-diagnostics.git
   cd terraform-azurerm-diagnostics
   ```

3. Add the upstream repository as a remote:
   ```bash
   git remote add upstream https://github.com/excellere-it/terraform-azurerm-diagnostics.git
   ```

4. Install dependencies and verify your setup:
   ```bash
   make validate
   ```

## Development Workflow

### Branching Strategy

- `main` - Production-ready code, protected branch
- `develop` - Integration branch for features (if used)
- `feature/*` - Feature branches
- `bugfix/*` - Bug fix branches
- `hotfix/*` - Hotfix branches for urgent production issues

### Making Changes

1. **Create a feature branch** from `main`:
   ```bash
   git checkout main
   git pull upstream main
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the [coding standards](#coding-standards)

3. **Format your code**:
   ```bash
   make fmt
   ```

4. **Validate your changes**:
   ```bash
   make validate
   ```

5. **Run tests**:
   ```bash
   make test
   ```

6. **Update documentation** if needed:
   ```bash
   make docs
   ```

7. **Commit your changes** with a descriptive message:
   ```bash
   git add .
   git commit -m "feat: add support for X"
   ```

   Follow [Conventional Commits](https://www.conventionalcommits.org/) format:
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation only
   - `style:` - Code style changes (formatting)
   - `refactor:` - Code refactoring
   - `test:` - Adding or updating tests
   - `chore:` - Maintenance tasks

8. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

### Running Development Commands

The Makefile provides convenient shortcuts:

```bash
make help          # Display all available targets
make dev           # Run development workflow (format, validate, docs)
make pre-commit    # Run all pre-commit checks
make test          # Run all tests
make clean         # Clean temporary files
```

## Pull Request Process

### Before Submitting

Ensure your PR meets these requirements:

- [ ] Code follows the [coding standards](#coding-standards)
- [ ] All tests pass (`make test`)
- [ ] Documentation is updated (`make docs`)
- [ ] Commit messages follow Conventional Commits format
- [ ] PR description clearly explains the changes

### Submitting Your PR

1. Push your branch to your fork on GitHub
2. Open a Pull Request against the `main` branch
3. Fill out the PR template with:
   - **Description**: Clear explanation of what and why
   - **Type of Change**: Feature, bug fix, documentation, etc.
   - **Testing**: How you tested your changes
   - **Checklist**: Complete all items

4. Link any related issues using keywords:
   - `Fixes #123`
   - `Closes #456`
   - `Relates to #789`

### PR Review Process

1. Automated checks will run (format, validate, test, security scan)
2. A maintainer will review your PR
3. Address any feedback or requested changes
4. Once approved, a maintainer will merge your PR

### After Your PR is Merged

1. Delete your feature branch:
   ```bash
   git branch -d feature/your-feature-name
   git push origin --delete feature/your-feature-name
   ```

2. Update your local main branch:
   ```bash
   git checkout main
   git pull upstream main
   ```

## Coding Standards

### Terraform Style Guide

Follow the [Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html):

- Use 2 spaces for indentation
- Use lowercase and underscores for resource names and variables
- Group related resources together
- Use descriptive names that indicate purpose
- Add comments for complex logic
- Keep lines under 100 characters when possible

### File Organization

```
terraform-azurerm-diagnostics/
├── main.tf           # Primary module logic
├── variables.tf      # Input variable definitions
├── outputs.tf        # Output definitions
├── versions.tf       # Provider and version requirements
├── examples/         # Example configurations
│   ├── default/
│   ├── include/
│   └── storage/
└── tests/            # Test files
    ├── basic.tftest.hcl
    └── validation.tftest.hcl
```

### Resource Naming Conventions

- Resources: `azurerm_<resource_type>.<descriptive_name>`
- Data sources: `data.azurerm_<resource_type>.<descriptive_name>`
- Variables: Descriptive snake_case names
- Locals: Descriptive snake_case names

### Code Comments

Add comments for:
- Complex logic or algorithms
- Workarounds for known issues
- Non-obvious design decisions
- Public interfaces (variables, outputs)

Example:
```hcl
# Filter log categories based on the include parameter.
# An empty include list means all categories are enabled.
locals {
  selected_categories = { for k, v in data.azurerm_monitor_diagnostic_categories.categories :
    k => {
      logs = [for l in v.logs : l if contains(var.monitored_services[k].include, l) || length(var.monitored_services[k].include) == 0]
    }
  }
}
```

## Testing Guidelines

### Test Requirements

All changes must include appropriate tests:

- **New features**: Add tests in `tests/basic.tftest.hcl`
- **Input validation**: Add tests in `tests/validation.tftest.hcl`
- **Bug fixes**: Add regression tests

### Writing Tests

Tests use Terraform's native testing framework (requires Terraform >= 1.6.0).

Test structure:
```hcl
run "test_name" {
  command = plan  # Use 'plan' for validation tests

  variables {
    # Test-specific variable overrides
  }

  assert {
    condition     = <boolean expression>
    error_message = "Descriptive error message"
  }
}
```

### Running Tests Locally

```bash
# Run all tests
make test

# Run specific test file
make test-terraform-filter FILE=tests/basic.tftest.hcl

# Quick test without formatting
make test-quick
```

### Test Coverage

Aim for comprehensive coverage:
- Core functionality (happy path)
- Edge cases
- Error conditions
- Input validation
- Multiple configuration scenarios

## Documentation Standards

### Variable Documentation

All variables must include:
- `description` - Clear explanation of purpose
- `type` - Explicit type constraint
- `default` - Default value (if optional)

Example:
```hcl
variable "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace where diagnostics will be sent."
  type        = string
}
```

### Output Documentation

All outputs must include:
- `description` - Clear explanation of what is returned
- `value` - The output expression

Example:
```hcl
output "diagnostics" {
  description = "Map of diagnostic setting resources created by this module."
  value       = azurerm_monitor_diagnostic_setting.setting
}
```

### README Updates

When adding features:
1. Update the feature list
2. Add usage examples
3. Run `make docs` to regenerate documentation
4. Review the generated content

### Example Documentation

Each example should include:
- `main.tf` - Complete working example
- `versions.tf` - Provider configuration
- Comments explaining key concepts
- Variable definitions (if needed)

## Questions and Support

### Getting Help

- **Questions**: Open a [GitHub Discussion](https://github.com/excellere-it/terraform-azurerm-diagnostics/discussions)
- **Bug Reports**: Open a [GitHub Issue](https://github.com/excellere-it/terraform-azurerm-diagnostics/issues)
- **Feature Requests**: Open a [GitHub Issue](https://github.com/excellere-it/terraform-azurerm-diagnostics/issues) with the "enhancement" label

### Issue Guidelines

When opening an issue, please include:

**For Bugs:**
- Terraform version
- Module version
- Azure provider version
- Steps to reproduce
- Expected behavior
- Actual behavior
- Relevant code snippets
- Error messages

**For Features:**
- Use case and motivation
- Proposed solution
- Alternative solutions considered
- Compatibility implications

## License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to terraform-azurerm-diagnostics! 🎉
