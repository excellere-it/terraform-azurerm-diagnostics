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
