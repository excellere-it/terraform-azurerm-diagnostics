# terraform-azurerm-diagnostics

A Terraform module for configuring Azure Monitor diagnostic settings with Log Analytics integration. This utility module simplifies the configuration of diagnostic logging and metrics for Azure resources.

## Features

- 🔍 **Automatic Log Discovery** - Automatically discovers and enables all available diagnostic categories
- 🎯 **Selective Filtering** - Use the `include` parameter to enable only specific log categories
- 📊 **Metrics Collection** - Automatically enables all available metrics
- 💾 **Storage Support** - Special handling for Azure Storage Account sub-services
- 🏷️ **Flexible Configuration** - Supports multiple monitored services in a single module call
- 📝 **Log Analytics Integration** - Direct integration with Azure Log Analytics workspaces

## Quick Start

```hcl
module "diagnostics" {
  source = "git::https://github.com/excellere-it/terraform-azurerm-diagnostics.git?ref=v0.0.11"

  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  monitored_services = {
    my_keyvault = {
      id = azurerm_key_vault.main.id
    }
  }
}
```

## Use Cases

### Enable All Diagnostics (Default)
Enable all available diagnostic categories for a resource:
```hcl
monitored_services = {
  kv = {
    id = azurerm_key_vault.example.id
  }
}
```

### Selective Log Collection
Enable only specific log categories:
```hcl
monitored_services = {
  kv = {
    id      = azurerm_key_vault.example.id
    include = ["AuditEvent"]
  }
}
```

### Storage Account Monitoring
Monitor storage sub-services:
```hcl
monitored_services = {
  blob = {
    id    = "${azurerm_storage_account.example.id}/blobServices/default/"
    table = "None"
  }
}
```

## Documentation

- **[Examples](./examples/)** - Complete working examples
- **[Tests](./tests/)** - Test documentation and coverage
- **[Contributing](./CONTRIBUTING.md)** - Contribution guidelines
- **[Changelog](./CHANGELOG.md)** - Version history
- **[Workflows](./.github/workflows/)** - CI/CD documentation

## Testing

This module uses Terraform's native testing framework (Terraform >= 1.6.0).

```bash
# Run all tests
make test

# Run specific test file
make test-terraform-filter FILE=tests/basic.tftest.hcl

# Quick test without formatting
make test-quick
```

See [tests/README.md](./tests/README.md) for detailed testing documentation.

## Development

### Prerequisites

- Terraform >= 1.3
- terraform-docs (for documentation generation)
- Make (optional, for convenience commands)

### Common Commands

```bash
make help       # Show all available commands
make fmt        # Format code
make validate   # Validate configuration
make test       # Run tests
make docs       # Generate documentation
make pre-commit # Run all pre-commit checks
```

See [CONTRIBUTING.md](./CONTRIBUTING.md) for detailed development guidelines.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for details on:
- Code of conduct
- Development workflow
- Pull request process
- Coding standards
- Testing requirements

## License

[License details here]

---

<!-- BEGIN_TF_DOCS -->


## Example

```hcl
locals {
  location       = "centralus"
  tags           = module.name.tags
  test_namespace = random_pet.instance_id.id
}

data "azurerm_client_config" "current" {}

resource "random_pet" "instance_id" {}

resource "azurerm_resource_group" "example" {
  location = local.location
  name     = "rg-${local.test_namespace}"
  tags     = local.tags
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "la-${local.test_namespace}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_key_vault" "example" {
  enabled_for_disk_encryption = true
  location                    = azurerm_resource_group.example.location
  name                        = "kv${replace(local.test_namespace, "-", "")}"
  purge_protection_enabled    = false
  resource_group_name         = azurerm_resource_group.example.name
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  tags                        = local.tags
  tenant_id                   = data.azurerm_client_config.current.tenant_id
}

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

## Using the include parameter

```hcl
locals {
  location       = "centralus"
  tags           = module.name.tags
  test_namespace = random_pet.instance_id.id
}

data "azurerm_client_config" "current" {}
resource "random_pet" "instance_id" {}

resource "azurerm_resource_group" "example" {
  location = local.location
  name     = "rg-${local.test_namespace}"
  tags     = local.tags
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "la-${local.test_namespace}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_key_vault" "example" {
  enabled_for_disk_encryption = true
  location                    = azurerm_resource_group.example.location
  name                        = "kv${replace(local.test_namespace, "-", "")}"
  purge_protection_enabled    = false
  resource_group_name         = azurerm_resource_group.example.name
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  tags                        = local.tags
  tenant_id                   = data.azurerm_client_config.current.tenant_id
}

module "example" {
  source = "../.."

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  monitored_services = {
    kv = {
      id      = azurerm_key_vault.example.id
      include = ["AuditEvent"]
    }
  }
}
```

## Working with storage accounts

```hcl
locals {
  location       = "centralus"
  tags           = module.name.tags
  test_namespace = random_pet.instance_id.id
}

data "azurerm_client_config" "current" {}

resource "random_pet" "instance_id" {}

resource "azurerm_resource_group" "example" {
  location = local.location
  name     = "rg-${local.test_namespace}"
  tags     = local.tags
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "la-${local.test_namespace}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_storage_account" "example" {
  account_replication_type = "GRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.example.location
  name                     = "sa${replace(local.test_namespace, "-", "")}"
  resource_group_name      = azurerm_resource_group.example.name
  tags                     = local.tags
}

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

## Required Inputs

The following input variables are required:

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: The workspace to write logs into.

Type: `string`

### <a name="input_monitored_services"></a> [monitored\_services](#input\_monitored\_services)

Description: A map of service names to their resource ids that should be configured to send diagnostics to log analytics.

Type:

```hcl
map(object({
    id      = string
    table   = optional(string)
    include = optional(list(string), [])
  }))
```

## Optional Inputs

No optional inputs.

## Outputs

The following outputs are exported:

### <a name="output_diagnostic_setting_ids"></a> [diagnostic\_setting\_ids](#output\_diagnostic\_setting\_ids)

Description: Map of diagnostic setting IDs keyed by service name

### <a name="output_diagnostic_setting_names"></a> [diagnostic\_setting\_names](#output\_diagnostic\_setting\_names)

Description: Map of diagnostic setting names keyed by service name

### <a name="output_diagnostics"></a> [diagnostics](#output\_diagnostics)

Description: Map of all diagnostic settings with their full configuration

### <a name="output_monitored_services_summary"></a> [monitored\_services\_summary](#output\_monitored\_services\_summary)

Description: Summary of monitored services configuration including enabled log categories

### <a name="output_total_diagnostic_settings"></a> [total\_diagnostic\_settings](#output\_total\_diagnostic\_settings)

Description: Total number of diagnostic settings configured

## Resources

The following resources are used by this module:

- [azurerm_monitor_diagnostic_setting.setting](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_monitor_diagnostic_categories.categories](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_diagnostic_categories) (data source)

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.3)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.41)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (3.117.1)

## Modules

No modules.
<!-- END_TF_DOCS -->

## Update Docs

Run this command:

```
terraform-docs markdown document --output-file README.md --output-mode inject .
```