# Terraform Tests

This directory contains Terraform native tests for the terraform-azurerm-diagnostics module using HCL test files (`.tftest.hcl`).

## Table of Contents

- [Overview](#overview)
- [Test Files](#test-files)
- [Prerequisites](#prerequisites)
- [Running Tests](#running-tests)
- [Test Coverage](#test-coverage)
- [CI/CD Integration](#cicd-integration)
- [Writing New Tests](#writing-new-tests)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## Overview

The tests use Terraform's native testing framework introduced in Terraform 1.6.0. This approach provides:

- **Fast execution** - Plan-only tests run in seconds
- **No cost** - No actual Azure resources are created
- **Native integration** - Built into Terraform, no external dependencies
- **Type safety** - Full Terraform expression support
- **Easy maintenance** - Tests are written in the same language as the module

## Test Files

### basic.tftest.hcl

Tests core functionality of the module:

**Test Cases:**
- `verify_default_deployment` - Tests basic diagnostics setup for Key Vault
  - Validates diagnostic settings are created
  - Checks naming conventions (diag-* prefix)
  - Verifies Log Analytics workspace configuration
  - Confirms target resource IDs are assigned

- `verify_include_filter` - Tests selective log category filtering
  - Validates the include parameter functionality
  - Tests filtering specific log categories (AuditEvent)
  - Confirms diagnostic settings are created with filters

- `verify_storage_services` - Tests storage account diagnostics
  - Validates multiple service monitoring (blob and file services)
  - Tests the `table = "None"` parameter for storage services
  - Confirms log_analytics_destination_type is null when appropriate

**Coverage:** ~6 test assertions covering core module functionality

### validation.tftest.hcl

Tests input validation and edge cases:

**Test Cases:**
- `validate_required_fields` - Validates required variable inputs
- `validate_include_empty_list` - Tests default behavior with empty include list
- `validate_include_with_categories` - Tests specific category selection
- `validate_table_none` - Tests table parameter with "None" value
- `validate_table_dedicated` - Tests table parameter with "Dedicated" value
- `validate_table_omitted` - Tests optional table parameter
- `validate_multiple_services` - Tests multiple monitored services
- `validate_resource_id_keyvault` - Validates Key Vault resource ID format
- `validate_resource_id_storage_subresource` - Validates storage sub-resource IDs

**Coverage:** ~10 test assertions covering input validation and edge cases

## Prerequisites

### Required Software

- **Terraform** >= 1.6.0 (for native testing framework)
- **Azure CLI** (optional, for authentication in integration tests)

Check your Terraform version:
```bash
terraform version
```

If you need to upgrade:
```bash
# Using tfenv (recommended)
tfenv install 1.6.0
tfenv use 1.6.0

# Or download from https://www.terraform.io/downloads
```

### Azure Authentication

For plan-only tests (current configuration), authentication is not required as tests use `ARM_SKIP_PROVIDER_REGISTRATION=true`.

For integration tests that create actual resources, authenticate with Azure:
```bash
az login
```

## Running Tests

### All Tests

Run all tests in the directory:
```bash
# From module root
terraform test

# Or using Make
make test

# Verbose output
terraform test -verbose
make test  # Already uses verbose
```

### Specific Test File

Run tests from a specific file:
```bash
# Using Terraform
terraform test -filter=tests/basic.tftest.hcl

# Using Make
make test-terraform-filter FILE=tests/basic.tftest.hcl
```

### Specific Test Case

Run a specific test case within a file:
```bash
terraform test -filter=tests/basic.tftest.hcl -run=verify_default_deployment
```

### Quick Test Run

Run tests without formatting and documentation generation:
```bash
make test-quick
```

### Watch Mode

Run tests continuously while developing:
```bash
# Unix/Linux/macOS
watch -n 5 terraform test

# Windows PowerShell
while ($true) { cls; terraform test; sleep 5 }
```

## Test Coverage

### Current Coverage Matrix

| Feature | Basic Tests | Validation Tests | Status |
|---------|-------------|------------------|--------|
| Default diagnostics | ✅ | ✅ | Covered |
| Include filter | ✅ | ✅ | Covered |
| Storage services | ✅ | ✅ | Covered |
| Multiple services | ✅ | ✅ | Covered |
| Table parameter | ✅ | ✅ | Covered |
| Resource ID format | ❌ | ✅ | Covered |
| Error handling | ❌ | ⚠️ | Partial |
| Output values | ⚠️ | ❌ | Partial |

**Legend:**
- ✅ Fully covered
- ⚠️ Partially covered
- ❌ Not covered

### Test Statistics

- **Total test files:** 2
- **Total test cases:** ~16
- **Total assertions:** ~20+
- **Execution time:** ~10-30 seconds (plan-only)
- **Azure cost:** $0 (no resources created)

## CI/CD Integration

Tests are automatically run in GitHub Actions on:
- Pull requests to `main` or `develop` branches
- Pushes to `main` or `develop` branches
- Manual workflow dispatch

### GitHub Actions Workflow

The `.github/workflows/test.yml` workflow includes:

1. **Format Check** - Validates Terraform formatting
2. **Validate** - Validates Terraform configuration
3. **Test Matrix** - Runs tests in parallel by file
4. **Test All** - Runs all tests together
5. **Coverage Report** - Generates coverage summary
6. **Security Scan** - Runs Checkov security analysis
7. **Lint** - Runs TFLint for best practices
8. **Summary** - Aggregates all results

### Viewing CI/CD Results

- **Pull Request**: Results appear as checks on the PR
- **Actions Tab**: View detailed logs in GitHub Actions
- **Artifacts**: Download test logs and results (retained for 7-30 days)

### CI/CD Command Equivalents

Run locally what CI runs:
```bash
# Full CI workflow
make pre-commit

# Individual steps
terraform fmt -check -recursive  # Format check
terraform validate               # Validation
terraform test -verbose          # Tests
```

## Writing New Tests

### Test File Structure

```hcl
# Test file header with description
run "test_name" {
  command = plan  # or 'apply' for integration tests

  # Override module source if needed
  module {
    source = "./examples/default"
  }

  # Override variables
  variables {
    variable_name = "value"
  }

  # Assertions
  assert {
    condition     = <boolean expression>
    error_message = "Clear, descriptive error message"
  }
}
```

### Adding a New Test Case

1. **Choose the appropriate file:**
   - `basic.tftest.hcl` - Core functionality
   - `validation.tftest.hcl` - Input validation
   - Create new file if needed for specific category

2. **Write the test:**
   ```hcl
   run "test_new_feature" {
     command = plan

     variables {
       # Test-specific configuration
     }

     assert {
       condition     = # Test condition
       error_message = "What went wrong and why"
     }
   }
   ```

3. **Run and verify:**
   ```bash
   terraform test -filter=tests/your_file.tftest.hcl -verbose
   ```

4. **Document in this README:**
   - Add to test coverage matrix
   - Update test statistics
   - Add to appropriate test file section

### Test Naming Conventions

- Use descriptive names: `verify_`, `validate_`, `test_`
- Be specific: `verify_storage_services` not `test_storage`
- Indicate purpose: `validate_table_none` not `test_table`

### Assertion Best Practices

**Good assertions:**
```hcl
assert {
  condition     = length(module.example.diagnostics) > 0
  error_message = "Module should create at least one diagnostic setting"
}

assert {
  condition     = alltrue([for k, v in module.example.diagnostics : can(regex("^diag-", v.name))])
  error_message = "All diagnostic setting names must start with 'diag-' prefix"
}
```

**Avoid:**
```hcl
# Too vague
assert {
  condition     = module.example.diagnostics != null
  error_message = "Failed"
}

# Testing implementation details
assert {
  condition     = length(local.internal_variable) == 3
  error_message = "Internal variable has wrong length"
}
```

## Troubleshooting

### Common Issues

#### Test Fails: "Terraform 1.6.0 or later is required"

**Solution:** Upgrade Terraform:
```bash
terraform version  # Check current version
# Upgrade using your package manager or download from terraform.io
```

#### Test Fails: "Error: Module not found"

**Solution:** Ensure you're running from the module root:
```bash
cd /path/to/terraform-azurerm-diagnostics
terraform test
```

#### Test Fails: "Provider authentication failed"

**Solution:** For plan-only tests, this shouldn't happen. If it does:
```bash
export ARM_SKIP_PROVIDER_REGISTRATION=true
terraform test
```

#### Test Fails: "Assertion failed"

**Solution:** Check the error message for details:
```bash
terraform test -verbose  # See full output
```

Then:
1. Review the assertion condition
2. Check if expected behavior changed
3. Update test or fix module logic

### Getting Help

- **Check test output:** `terraform test -verbose`
- **Review module logic:** Check `main.tf` for implementation
- **Consult documentation:** See module README.md
- **Open an issue:** [GitHub Issues](https://github.com/excellere-it/terraform-azurerm-diagnostics/issues)

## Best Practices

### Do's

✅ **Use plan-only tests** for validation (fast and free)
```hcl
run "test_name" {
  command = plan  # Not apply
}
```

✅ **Write clear error messages**
```hcl
error_message = "Diagnostic settings should use the specified workspace ID, got: ${module.example.diagnostics.workspace_id}"
```

✅ **Test both success and failure cases**
```hcl
run "valid_input" {
  # Should succeed
}

run "invalid_input" {
  expect_failures = [var.some_variable]
  # Should fail validation
}
```

✅ **Keep tests focused and atomic**
```hcl
# One test per feature/scenario
run "verify_include_filter" { }
run "verify_storage_services" { }
```

✅ **Use descriptive test names**
```hcl
run "verify_log_analytics_workspace_configuration" { }  # Good
run "test1" { }  # Bad
```

### Don'ts

❌ **Don't create real resources** in CI tests (use `command = plan`)

❌ **Don't test provider behavior**
```hcl
# Bad - testing Azure provider, not our module
assert {
  condition     = data.azurerm_monitor_diagnostic_categories.test.metrics != null
  error_message = "Azure should return metrics"
}
```

❌ **Don't use hard-coded values** when dynamic is possible
```hcl
# Bad
assert {
  condition     = module.example.diagnostics["kv"].name == "diag-kv"
}

# Better
assert {
  condition     = can(regex("^diag-", module.example.diagnostics["kv"].name))
}
```

❌ **Don't skip test documentation**

---

## Additional Resources

- [Terraform Testing Documentation](https://www.terraform.io/docs/language/tests.html)
- [Module README](../README.md)
- [Contributing Guide](../CONTRIBUTING.md)
- [GitHub Actions Workflow](.github/workflows/test.yml)

---

**Questions or suggestions?** Open an issue or contribute improvements to this documentation!
