# =============================================================================
# Terraform Module Makefile
# =============================================================================
# Comprehensive Makefile for terraform-azurerm-diagnostics module development
#
# Usage:
#   make <target>
#
# Run 'make help' to see all available targets

.PHONY: help docs fmt tffmt gofmt validate test tidy upgrade clean deploy init plan pre-commit security-scan \
        test-terraform test-quick test-specific test-terraform-filter test-all \
        lint dev check ci-test info

# Default target
.DEFAULT_GOAL := help

# Variables
TESTDIR := ./test
EXAMPLE_DIR := ./examples/default
example ?= default
TEST ?= TestDefault
FILE ?=

# Color codes for output
COLOR_RESET := \033[0m
COLOR_BOLD := \033[1m
COLOR_GREEN := \033[32m
COLOR_YELLOW := \033[33m
COLOR_BLUE := \033[34m

# =============================================================================
# Help Target
# =============================================================================

help: ## Display this help message
	@echo "$(COLOR_BOLD)Available targets:$(COLOR_RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(COLOR_GREEN)%-20s$(COLOR_RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(COLOR_BOLD)Examples:$(COLOR_RESET)"
	@echo "  make test                    # Run validation tests"
	@echo "  make test-terraform          # Run Terraform native tests"
	@echo "  make deploy example=default  # Deploy default example"
	@echo "  make destroy example=storage # Destroy storage example"
	@echo ""

# =============================================================================
# Documentation Targets
# =============================================================================

docs: ## Generate Terraform documentation
	@echo "$(COLOR_BLUE)Generating Terraform documentation...$(COLOR_RESET)"
	@terraform-docs markdown document --output-file README.md --output-mode inject .
	@echo "$(COLOR_GREEN)Documentation generated successfully!$(COLOR_RESET)"

# =============================================================================
# Formatting Targets
# =============================================================================

tffmt: ## Format Terraform files
	@echo "$(COLOR_BLUE)Formatting Terraform files...$(COLOR_RESET)"
	@terraform fmt -recursive
	@echo "$(COLOR_GREEN)Terraform files formatted!$(COLOR_RESET)"

gofmt: ## Format Go test files
	@echo "$(COLOR_YELLOW)Formatting Go files...$(COLOR_RESET)"
	@cd $(TESTDIR) && go fmt
	@echo "$(COLOR_GREEN)✓ Go files formatted$(COLOR_RESET)"

fmt: tffmt gofmt ## Format all files (Terraform and Go)

# =============================================================================
# Dependencies
# =============================================================================

tidy: ## Tidy Go module dependencies
	@echo "$(COLOR_YELLOW)Tidying Go dependencies...$(COLOR_RESET)"
	@cd $(TESTDIR) && go mod tidy
	@echo "$(COLOR_GREEN)✓ Go dependencies tidied$(COLOR_RESET)"

# =============================================================================
# Validation Targets
# =============================================================================

validate: ## Validate Terraform configuration
	@echo "$(COLOR_BLUE)Validating Terraform configuration...$(COLOR_RESET)"
	@terraform init -backend=false > /dev/null
	@terraform validate
	@echo "$(COLOR_GREEN)Validation successful!$(COLOR_RESET)"

# =============================================================================
# Testing Targets
# =============================================================================

test: tidy fmt docs ## Run all tests (Go-based Terratest)
	@echo "$(COLOR_YELLOW)Running tests...$(COLOR_RESET)"
	@cd $(TESTDIR) && go test -v --timeout=30m
	@echo "$(COLOR_GREEN)✓ All tests passed$(COLOR_RESET)"

test-quick: ## Run tests without formatting and docs generation
	@echo "$(COLOR_YELLOW)Running tests...$(COLOR_RESET)"
	@cd $(TESTDIR) && go test -v --timeout=30m

test-specific: ## Run specific test (usage: make test-specific TEST=TestDefault)
	@echo "$(COLOR_YELLOW)Running test: $(TEST)...$(COLOR_RESET)"
	@cd $(TESTDIR) && go test -v -run $(TEST) --timeout=30m

test-terraform: ## Run native Terraform tests (requires Terraform >= 1.6.0)
	@echo "$(COLOR_YELLOW)Running Terraform native tests...$(COLOR_RESET)"
	@terraform test -verbose
	@echo "$(COLOR_GREEN)✓ All Terraform tests passed$(COLOR_RESET)"

test-terraform-filter: ## Run specific Terraform test file (usage: make test-terraform-filter FILE=tests/basic.tftest.hcl)
	@echo "$(COLOR_YELLOW)Running Terraform test: $(FILE)...$(COLOR_RESET)"
	@terraform test -filter=$(FILE) -verbose

test-all: tidy fmt docs test-terraform ## Run all tests (both Go and Terraform native)
	@echo "$(COLOR_YELLOW)Running Go tests...$(COLOR_RESET)"
	@cd $(TESTDIR) && go test -v --timeout=30m
	@echo "$(COLOR_GREEN)========================================$(COLOR_RESET)"
	@echo "$(COLOR_GREEN)✓ All tests passed (Go + Terraform)!$(COLOR_RESET)"
	@echo "$(COLOR_GREEN)========================================$(COLOR_RESET)"

# =============================================================================
# Deployment
# =============================================================================

init: ## Initialize Terraform in example directory
	@echo "$(COLOR_YELLOW)Initializing Terraform...$(COLOR_RESET)"
	@cd $(EXAMPLE_DIR) && terraform init
	@echo "$(COLOR_GREEN)✓ Terraform initialized$(COLOR_RESET)"

plan: init ## Create Terraform plan
	@echo "$(COLOR_YELLOW)Creating Terraform plan...$(COLOR_RESET)"
	@cd $(EXAMPLE_DIR) && terraform plan

deploy: init ## Deploy example configuration
	@echo "$(COLOR_YELLOW)Deploying example: $(example)...$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)This will create real Azure resources and may incur costs.$(COLOR_RESET)"
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd ./examples/$(example) && terraform apply; \
		echo "$(COLOR_GREEN)Deployment complete!$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_YELLOW)Deployment cancelled.$(COLOR_RESET)"; \
	fi

destroy: ## Destroy deployed example resources
	@echo "$(COLOR_YELLOW)Destroying example: $(example)...$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)This will delete Azure resources.$(COLOR_RESET)"
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd ./examples/$(example) && terraform destroy; \
		echo "$(COLOR_GREEN)Resources destroyed!$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_YELLOW)Destroy cancelled.$(COLOR_RESET)"; \
	fi

upgrade: ## Upgrade Terraform provider versions
	@echo "$(COLOR_BLUE)Upgrading provider versions for example: $(example)...$(COLOR_RESET)"
	@cd ./examples/$(example) && terraform init -upgrade
	@echo "$(COLOR_GREEN)Providers upgraded!$(COLOR_RESET)"

# =============================================================================
# Maintenance Targets
# =============================================================================

clean: ## Clean temporary files and caches
	@echo "$(COLOR_BLUE)Cleaning temporary files...$(COLOR_RESET)"
	@find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.tfstate" -delete 2>/dev/null || true
	@find . -type f -name "*.tfstate.backup" -delete 2>/dev/null || true
	@find . -type f -name "terraform.test.tfstate" -delete 2>/dev/null || true
	@find . -type f -name "*.tfplan" -delete 2>/dev/null || true
	@find . -type f -name "crash.log" -delete 2>/dev/null || true
	@echo "$(COLOR_GREEN)Cleanup complete!$(COLOR_RESET)"

# =============================================================================
# Security & Quality Targets
# =============================================================================

security-scan: ## Run tfsec security scanner
	@echo "$(COLOR_BLUE)Running security scan...$(COLOR_RESET)"
	@if command -v tfsec > /dev/null; then \
		tfsec .; \
		echo "$(COLOR_GREEN)Security scan complete!$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_YELLOW)tfsec not installed. Install from: https://github.com/aquasecurity/tfsec$(COLOR_RESET)"; \
	fi

lint: ## Run TFLint linter
	@echo "$(COLOR_BLUE)Running TFLint...$(COLOR_RESET)"
	@if command -v tflint > /dev/null; then \
		tflint --init && tflint; \
		echo "$(COLOR_GREEN)Linting complete!$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_YELLOW)tflint not installed. Install from: https://github.com/terraform-linters/tflint$(COLOR_RESET)"; \
	fi

# =============================================================================
# Development Workflow Targets
# =============================================================================

pre-commit: fmt validate docs test ## Run all pre-commit checks
	@echo "$(COLOR_GREEN)All pre-commit checks passed!$(COLOR_RESET)"

dev: fmt validate docs ## Run development workflow (format, validate, docs)
	@echo "$(COLOR_GREEN)Development workflow complete!$(COLOR_RESET)"

check: fmt validate ## Quick quality check
	@echo "$(COLOR_GREEN)Quality check passed!$(COLOR_RESET)"

ci-test: validate test ## Run tests in CI environment
	@echo "$(COLOR_GREEN)CI tests complete!$(COLOR_RESET)"

# =============================================================================
# Information Targets
# =============================================================================

info: ## Display project information
	@echo "$(COLOR_BOLD)Module Information$(COLOR_RESET)"
	@echo "  Name: terraform-azurerm-diagnostics"
	@echo "  Type: Terraform Module for Azure Monitor Diagnostics"
	@echo ""
	@echo "$(COLOR_BOLD)Terraform Version$(COLOR_RESET)"
	@terraform version
	@echo ""
	@echo "$(COLOR_BOLD)Available Examples$(COLOR_RESET)"
	@ls -1 examples/
	@echo ""
	@echo "$(COLOR_BOLD)Test Files$(COLOR_RESET)"
	@ls -1 tests/*.tftest.hcl 2>/dev/null || echo "  No test files found"
