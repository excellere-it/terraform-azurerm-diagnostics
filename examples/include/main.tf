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
