# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.5] - 2025-01-13

### Fixed
- Added `try()` function to handle cases where diagnostic categories data source doesn't return logs attribute
- Fixes compatibility with Log Analytics Workspaces and other resources that may not have log categories

## [0.0.4] - 2025-01-13

### Added
- Migrated to Terraform native testing framework (HCL) from Go/Terratest
- Comprehensive GitHub Actions CI/CD workflow (test.yml)
- Enhanced Makefile with comprehensive development targets
- CONTRIBUTING.md with detailed development guidelines
- Comprehensive .gitignore with security patterns
- Test documentation (tests/README.md)
- Examples documentation (examples/README.md)
- Workflow documentation (.github/workflows/README.md)
- Security scanning integration (Checkov)
- Linting integration (TFLint)
- Test coverage reporting

### Changed
- Updated Makefile structure to match reference modules
- Improved test organization with separate basic and validation test files
- Enhanced documentation structure

### Removed
- Go-based Terratest files (test/module_test.go, test/go.mod, test/go.sum)

## [0.0.11] - 2024-XX-XX

### Changed
- Update version constraint

## [0.0.10] - 2024-XX-XX

### Changed
- Update Namer in examples

## [0.0.9] - 2024-XX-XX

### Added
- Add Makefile destroy target

## Previous Versions

For changes prior to v0.0.9, please refer to the git commit history.

---

## Version Guidelines

### Versioning Strategy

This project uses [Semantic Versioning](https://semver.org/):
- **MAJOR** version (X.0.0) - Incompatible API changes
- **MINOR** version (0.X.0) - Backwards-compatible functionality additions
- **PATCH** version (0.0.X) - Backwards-compatible bug fixes

### Pre-1.0.0 Notice

While the module is in 0.x.x versions, the API may change without warning. Once we reach 1.0.0, we will follow strict semantic versioning for breaking changes.

### Release Process

1. Update CHANGELOG.md with changes
2. Update version references if needed
3. Create a git tag: `git tag -a v0.0.12 -m "Release v0.0.12"`
4. Push the tag: `git push origin v0.0.12`
5. GitHub Actions will automatically create a release

### Change Categories

- **Added** - New features
- **Changed** - Changes in existing functionality
- **Deprecated** - Soon-to-be removed features
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Security fixes or improvements

---

## Links

- [Repository](https://github.com/excellere-it/terraform-azurerm-diagnostics)
- [Issues](https://github.com/excellere-it/terraform-azurerm-diagnostics/issues)
- [Releases](https://github.com/excellere-it/terraform-azurerm-diagnostics/releases)
