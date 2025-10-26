# GitHub Actions Workflows

This directory contains CI/CD workflows for the terraform-azurerm-diagnostics module using GitHub Actions.

## Table of Contents

- [Overview](#overview)
- [Workflows](#workflows)
- [Requirements](#requirements)
- [Local Testing](#local-testing)
- [Workflow Status](#workflow-status)
- [Troubleshooting](#troubleshooting)

## Overview

The module uses GitHub Actions for automated testing, validation, and releases. All workflows are defined using YAML files in this directory.

### Workflow Triggers

Workflows are triggered by:
- **Push** to `main` or `develop` branches
- **Pull Requests** to `main` or `develop` branches
- **Tags** matching version patterns
- **Manual dispatch** (workflow_dispatch)

## Workflows

### test.yml - Comprehensive Testing Pipeline

**Purpose:** Validates code quality, runs tests, and performs security scanning

**Triggers:**
- Push to `main` or `develop` (when `.tf`, `tests/**`, or `examples/**` files change)
- Pull requests to `main` or `develop`
- Manual workflow dispatch

**Jobs:**

1. **terraform-format** (Ubuntu)
   - Checks Terraform code formatting
   - Runs: `terraform fmt -check -recursive`
   - Fails if code is not formatted

2. **terraform-validate** (Ubuntu)
   - Validates Terraform configuration syntax
   - Runs: `terraform init -backend=false` + `terraform validate`
   - Depends on: terraform-format

3. **terraform-test** (Matrix, Ubuntu)
   - Runs tests in parallel by file
   - Matrix strategy for faster execution
   - Files: `tests/basic.tftest.hcl`, `tests/validation.tftest.hcl`
   - Uploads test results as artifacts (7-day retention)
   - Depends on: terraform-format, terraform-validate

4. **terraform-test-all** (Ubuntu)
   - Runs all tests together with verbose output
   - Generates test summary in job summary
   - Comments PR with test results
   - Uploads test logs (30-day retention)
   - Depends on: terraform-format, terraform-validate

5. **test-coverage-report** (Ubuntu)
   - Generates coverage summary
   - Documents test files and coverage areas
   - Always runs (even if tests fail)
   - Depends on: terraform-test-all

6. **security-scan** (Ubuntu)
   - Runs Checkov security scanner
   - Scans for security misconfigurations
   - Output format: SARIF
   - Soft fail (informational)
   - Uploads results (30-day retention)
   - Depends on: terraform-validate

7. **lint** (Ubuntu)
   - Runs TFLint for best practices
   - Checks deprecated syntax
   - Continue on error (informational)
   - Depends on: terraform-validate

8. **terraform-docs** (Ubuntu)
   - Validates documentation is up-to-date
   - Fails if README.md needs regeneration
   - Uses terraform-docs GitHub Action

9. **test-summary** (Ubuntu)
   - Aggregates results from all jobs
   - Creates comprehensive summary
   - Fails if critical tests fail
   - Depends on: all previous jobs

**Permissions:**
```yaml
permissions:
  contents: read
  pull-requests: write
```

**Environment Variables:**
- `ARM_SKIP_PROVIDER_REGISTRATION=true` (for plan-only tests)

---

### release-module.yml - Release Automation

**Purpose:** Automates module releases when version tags are pushed

**Triggers:**
- Tags matching `0.0.*` pattern (e.g., `0.0.12`, `0.0.13`)

**Jobs:**

1. **release** (Ubuntu)
   - Creates GitHub Release from tag
   - Generates release notes from git history
   - Uses `softprops/action-gh-release@v3`

**Permissions:**
```yaml
permissions:
  contents: write
```

**Creating a Release:**
```bash
# Update CHANGELOG.md with changes
vim CHANGELOG.md

# Commit changes
git add CHANGELOG.md
git commit -m "chore: prepare for v0.0.12 release"
git push

# Create and push tag
git tag -a v0.0.12 -m "Release v0.0.12"
git push origin v0.0.12

# GitHub Actions will automatically create the release
```

---

## Requirements

### Terraform Version

- **Minimum:** 1.6.0 (for native testing framework)
- **Specified in workflows:** ~1.6.0

### GitHub Actions

- `actions/checkout@v4` - Repository checkout
- `hashicorp/setup-terraform@v3` - Terraform installation
- `actions/upload-artifact@v4` - Artifact uploads
- `actions/github-script@v7` - PR commenting
- `bridgecrewio/checkov-action@v12` - Security scanning
- `terraform-linters/setup-tflint@v4` - TFLint setup
- `terraform-docs/gh-actions@v1` - Documentation validation
- `softprops/action-gh-release@v3` - Release creation

### Secrets

No secrets are currently required for the workflows. Azure authentication is skipped for plan-only tests.

For future integration tests that create actual resources, add:
- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

## Local Testing

Run the same checks that CI runs:

### Format Check
```bash
# Check formatting
terraform fmt -check -recursive

# Fix formatting
make fmt
```

### Validation
```bash
# Validate configuration
terraform init -backend=false
terraform validate

# Or using Make
make validate
```

### Tests
```bash
# Run all tests
terraform test -verbose

# Or using Make
make test
```

### Security Scan
```bash
# Install checkov
pip install checkov

# Run scan
checkov -d . --framework terraform
```

### Linting
```bash
# Install tflint
# macOS
brew install tflint

# Linux
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Initialize and run
tflint --init
tflint
```

### Documentation Check
```bash
# Install terraform-docs
# macOS
brew install terraform-docs

# Generate docs
terraform-docs markdown document --output-file README.md --output-mode inject .

# Check if docs are up-to-date
git diff README.md
```

### Pre-commit Check (All)
```bash
# Run all checks
make pre-commit
```

## Workflow Status

### Viewing Workflow Status

**In Pull Requests:**
- Status checks appear at the bottom of the PR
- Click "Details" to view full logs
- Failed checks block merging (if required)

**In Actions Tab:**
- Navigate to: `Actions` tab in GitHub
- Click workflow name to see runs
- Click specific run to see job details
- Download artifacts from successful/failed runs

### Status Badges

Add workflow badges to README.md:

```markdown
![Test](https://github.com/excellere-it/terraform-azurerm-diagnostics/workflows/Test/badge.svg)
![Release](https://github.com/excellere-it/terraform-azurerm-diagnostics/workflows/Release/badge.svg)
```

### Artifact Downloads

Artifacts are retained for:
- **Test results (matrix):** 7 days
- **Test logs (all):** 30 days
- **Security scan results:** 30 days

Download artifacts from:
1. Actions tab → Workflow run → Artifacts section
2. Or via GitHub API

## Troubleshooting

### Test Workflow Fails

#### "Terraform format check failed"

**Cause:** Code is not formatted according to Terraform standards

**Solution:**
```bash
make fmt
git add .
git commit -m "style: format code"
git push
```

#### "Terraform validation failed"

**Cause:** Invalid Terraform syntax or configuration

**Solution:**
```bash
make validate
# Fix reported errors
git add .
git commit -m "fix: correct validation errors"
git push
```

#### "Tests failed"

**Cause:** Test assertions failed or configuration errors

**Solution:**
1. View test logs in Actions
2. Run tests locally: `make test`
3. Fix failing tests or module logic
4. Push fixes

#### "Documentation check failed"

**Cause:** README.md is out of date

**Solution:**
```bash
make docs
git add README.md
git commit -m "docs: update generated documentation"
git push
```

### Release Workflow Fails

#### "Tag already exists"

**Cause:** Version tag already used

**Solution:**
```bash
# Delete local tag
git tag -d v0.0.12

# Delete remote tag
git push origin :refs/tags/v0.0.12

# Create new tag with incremented version
git tag -a v0.0.13 -m "Release v0.0.13"
git push origin v0.0.13
```

#### "Release creation failed"

**Cause:** Permissions issue or invalid tag format

**Solution:**
1. Verify tag matches pattern: `0.0.*`
2. Check repository permissions
3. Ensure `contents: write` permission is granted

### Performance Issues

#### "Workflows take too long"

**Current timing:**
- Format check: ~30 seconds
- Validation: ~30 seconds
- Tests (matrix): ~1-2 minutes (parallel)
- Security scan: ~1-2 minutes
- Total: ~5-7 minutes

**Optimization tips:**
- Matrix strategy already parallelizes tests
- Consider caching Terraform providers
- Use path filters to skip unnecessary runs

#### "Too many workflow runs"

**Solution:**
Add path filters to skip runs when only docs change:

```yaml
paths-ignore:
  - '**.md'
  - 'docs/**'
```

### Security Scan Warnings

#### "Checkov found issues"

**Note:** Security scan is set to `soft_fail: true` (informational only)

**Review findings:**
1. Download SARIF artifact
2. Review reported issues
3. Fix legitimate security concerns
4. Document false positives if needed

---

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform Testing Documentation](https://www.terraform.io/docs/language/tests.html)
- [Checkov Documentation](https://www.checkov.io/documentation.html)
- [TFLint Documentation](https://github.com/terraform-linters/tflint)

---

**Questions?** Open an issue or check the [Contributing Guide](../../CONTRIBUTING.md)!
