# Examples

This directory contains example configurations demonstrating different use cases for the terraform-azurerm-diagnostics module.

## Table of Contents

- [Available Examples](#available-examples)
- [Prerequisites](#prerequisites)
- [Running Examples](#running-examples)
- [Example Descriptions](#example-descriptions)
- [Customization](#customization)
- [Important Notes](#important-notes)
- [Contributing Examples](#contributing-examples)

## Available Examples

| Example | Description | Use Case |
|---------|-------------|----------|
| [default](./default/) | Basic diagnostics setup | Enable all diagnostic categories for a Key Vault |
| [include](./include/) | Selective log filtering | Enable only specific log categories (AuditEvent) |
| [storage](./storage/) | Storage account diagnostics | Monitor multiple storage services (blob, file) |

## Prerequisites

Before running these examples, ensure you have:

### Required Tools

- [Terraform](https://www.terraform.io/downloads.html) >= 1.3
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (for authentication)

### Azure Authentication

Authenticate with Azure before running examples:

```bash
# Interactive login
az login

# Or use service principal
az login --service-principal \
  --username $ARM_CLIENT_ID \
  --password $ARM_CLIENT_SECRET \
  --tenant $ARM_TENANT_ID
```

### Azure Permissions

You need permissions to create the following resources:
- Resource Groups
- Log Analytics Workspaces
- Key Vaults (for default and include examples)
- Storage Accounts (for storage example)
- Monitor Diagnostic Settings

## Running Examples

### Using Terraform Commands

Navigate to an example directory and run:

```bash
# Navigate to example
cd examples/default

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# When done, destroy resources
terraform destroy
```

### Using Make Commands

From the module root directory:

```bash
# Initialize an example
make init example=default

# Create a plan
make plan example=default

# Deploy an example
make deploy example=default

# Destroy an example
make destroy example=storage
```

### Example Workflow

Complete workflow for testing an example:

```bash
# 1. Navigate to module root
cd terraform-azurerm-diagnostics

# 2. Choose an example
make init example=include

# 3. Review what will be created
make plan example=include

# 4. Deploy (creates real Azure resources)
make deploy example=include

# 5. Verify resources in Azure Portal
# Browse to: https://portal.azure.com

# 6. Clean up resources
make destroy example=include
```

## Example Descriptions

### Default Example

**Location:** `examples/default/`

**Purpose:** Demonstrates the most basic usage of the module with default settings.

**What it creates:**
- Resource Group
- Log Analytics Workspace
- Key Vault
- Diagnostic Settings (all available log categories)

**Key Features:**
- Enables all diagnostic log categories automatically
- Uses default metric collection
- Demonstrates naming convention integration

**Usage:**
```hcl
module "example" {
  source = "../.."

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  monitored_services = {
    kv = {
      id = azurerm_key_vault.example.id
    }
  }
}
```

**When to use:**
- Starting point for new implementations
- Need comprehensive logging without filtering
- Simple, straightforward diagnostic collection

---

### Include Example

**Location:** `examples/include/`

**Purpose:** Demonstrates selective log category filtering using the `include` parameter.

**What it creates:**
- Resource Group
- Log Analytics Workspace
- Key Vault
- Diagnostic Settings (only specified log categories)

**Key Features:**
- Selective log category filtering
- Only "AuditEvent" logs are collected
- Reduces log volume and costs
- Demonstrates the `include` parameter

**Usage:**
```hcl
module "example" {
  source = "../.."

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  monitored_services = {
    kv = {
      id      = azurerm_key_vault.example.id
      include = ["AuditEvent"]  # Only collect audit events
    }
  }
}
```

**When to use:**
- Need specific log categories only
- Want to reduce logging costs
- Compliance requires specific audit logs
- Testing or development environments

---

### Storage Example

**Location:** `examples/storage/`

**Purpose:** Demonstrates diagnostic settings for Azure Storage Account sub-services.

**What it creates:**
- Resource Group
- Log Analytics Workspace
- Storage Account
- Diagnostic Settings for blob service
- Diagnostic Settings for file service

**Key Features:**
- Multiple monitored services
- Storage-specific `table = "None"` parameter
- Sub-resource monitoring (blobServices, fileServices)
- Demonstrates complex resource ID handling

**Usage:**
```hcl
module "example" {
  source = "../.."

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  monitored_services = {
    blobs = {
      id    = "${azurerm_storage_account.example.id}/blobServices/default/"
      table = "None"
    }
    files = {
      id    = "${azurerm_storage_account.example.id}/fileServices/default/"
      table = "None"
    }
  }
}
```

**When to use:**
- Monitoring Azure Storage Accounts
- Need diagnostics for specific storage services
- Understanding sub-resource diagnostic settings
- Production storage monitoring

---

## Customization

### Modifying Examples

You can customize examples by:

1. **Changing Variables:**
   ```hcl
   # In examples/*/main.tf
   locals {
     location = "eastus"  # Change region
   }
   ```

2. **Adding Tags:**
   ```hcl
   resource "azurerm_resource_group" "example" {
     tags = merge(local.tags, {
       "Environment" = "Development"
       "CostCenter"  = "Engineering"
     })
   }
   ```

3. **Changing Log Categories:**
   ```hcl
   monitored_services = {
     kv = {
       id      = azurerm_key_vault.example.id
       include = ["AuditEvent", "AzurePolicyEvaluationDetails"]
     }
   }
   ```

4. **Adding More Services:**
   ```hcl
   monitored_services = {
     kv = {
       id = azurerm_key_vault.example.id
     }
     storage = {
       id = azurerm_storage_account.example.id
     }
   }
   ```

### Creating Custom Examples

1. **Create a new directory:**
   ```bash
   mkdir examples/my-custom-example
   cd examples/my-custom-example
   ```

2. **Create configuration files:**
   ```hcl
   # main.tf
   # versions.tf
   # (optional) variables.tf
   # (optional) outputs.tf
   ```

3. **Test your example:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Add to this README** under Available Examples

## Important Notes

### Costs

⚠️ **These examples create real Azure resources that may incur costs:**

| Resource | Estimated Monthly Cost |
|----------|------------------------|
| Log Analytics Workspace | $2.30/GB ingested + retention |
| Key Vault | $0.03 per 10,000 operations |
| Storage Account | $0.018/GB + transactions |
| Diagnostic Settings | No direct cost |

**Cost Management Tips:**
- Destroy resources immediately after testing
- Use selective log filtering (`include` parameter)
- Set appropriate retention periods
- Use development/test subscriptions

### Naming

All examples use random naming with `random_pet` to avoid conflicts:
- Resource Group: `rg-<random-pet>`
- Workspace: `la-<random-pet>`
- Key Vault: `kv<random-pet>` (no hyphens due to naming constraints)
- Storage: `sa<random-pet>` (no hyphens due to naming constraints)

This ensures multiple people can run examples simultaneously without conflicts.

### Cleanup

Always destroy resources after testing:

```bash
# Using Terraform
cd examples/default
terraform destroy

# Using Make
make destroy example=default
```

### Region Selection

Examples default to `centralus`. You may want to change this based on:
- Your geographic location (lower latency)
- Available Azure services in the region
- Pricing differences between regions
- Data residency requirements

Change region in `locals`:
```hcl
locals {
  location = "eastus"  # or "westeurope", "southeastasia", etc.
}
```

## Contributing Examples

We welcome contributions of new examples! To contribute:

### Example Guidelines

Your example should:
1. Demonstrate a specific use case or feature
2. Be well-documented with comments
3. Include all required files (main.tf, versions.tf)
4. Use appropriate naming conventions
5. Be tested and working
6. Include cost estimates
7. Be added to this README

### Submission Process

1. Fork the repository
2. Create your example in `examples/your-example/`
3. Test thoroughly
4. Update this README with your example
5. Submit a Pull Request

See [CONTRIBUTING.md](../CONTRIBUTING.md) for detailed guidelines.

---

## Questions and Support

- **Module Documentation:** [README.md](../README.md)
- **Testing Documentation:** [tests/README.md](../tests/README.md)
- **Contributing Guide:** [CONTRIBUTING.md](../CONTRIBUTING.md)
- **Issues:** [GitHub Issues](https://github.com/excellere-it/terraform-azurerm-diagnostics/issues)

---

**Ready to try the examples?** Start with the [default](./default/) example to get familiar with the module!
