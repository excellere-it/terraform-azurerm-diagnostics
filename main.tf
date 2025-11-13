# =============================================================================
# Module: Azure Monitor Diagnostic Settings
# =============================================================================
#
# Purpose:
#   This module provides standardized configuration of Azure Monitor diagnostic
#   settings for Azure resources with Log Analytics workspace integration. It
#   automates the discovery and enablement of diagnostic logs and metrics,
#   reducing manual configuration effort and ensuring consistent monitoring
#   across all Azure resources.
#
# Features:
#   - Automatic Discovery: Queries Azure to discover all available diagnostic
#     categories (logs and metrics) for each monitored resource
#   - Selective Filtering: Optional include parameter to enable only specific
#     log categories instead of all available logs
#   - Metrics Collection: Automatically enables all available metrics for
#     comprehensive resource monitoring
#   - Storage Account Support: Special handling for Azure Storage Account
#     sub-services (blob, file, queue, table) with table destination control
#   - Multi-Resource Support: Configure multiple resources in a single module
#     call using a map-based configuration approach
#   - Log Analytics Integration: Direct integration with Azure Log Analytics
#     workspaces for centralized log management
#   - Zero Retention: Configures diagnostic settings with zero retention to
#     leverage Log Analytics workspace retention policies
#   - Lifecycle Management: Handles Azure API quirks with lifecycle rules for
#     log_analytics_destination_type attribute
#
# Resources Created:
#   - azurerm_monitor_diagnostic_setting: Creates diagnostic settings for each
#     monitored service to send logs and metrics to Log Analytics
#
# Data Sources Used:
#   - azurerm_monitor_diagnostic_categories: Queries available diagnostic
#     categories (logs and metrics) for each monitored resource
#
# Dependencies:
#   - None (standalone utility module)
#   - Requires existing Log Analytics workspace (ID provided as input)
#   - Requires existing Azure resources to monitor (IDs provided as input)
#
# Usage Patterns:
#
#   1. Enable All Diagnostics (Default):
#      monitored_services = {
#        my_resource = {
#          id = azurerm_key_vault.example.id
#        }
#      }
#
#   2. Selective Log Collection:
#      monitored_services = {
#        my_resource = {
#          id      = azurerm_key_vault.example.id
#          include = ["AuditEvent", "AzurePolicyEvaluationDetails"]
#        }
#      }
#
#   3. Storage Account Sub-Services:
#      monitored_services = {
#        storage_blob = {
#          id    = "${azurerm_storage_account.example.id}/blobServices/default/"
#          table = "None"  # Use "None" for storage sub-services
#        }
#      }
#
# Important Notes:
#   - The module creates diagnostic settings with retention disabled (days = 0)
#     to rely on Log Analytics workspace retention configuration
#   - Storage account sub-services require special handling with table = "None"
#   - Empty include list [] means enable ALL available log categories
#   - Non-empty include list means enable ONLY specified log categories
#   - Metrics are always fully enabled regardless of log filtering
#   - Resource names follow pattern: "diag-{service_key}" where service_key
#     is the map key from monitored_services variable
#
# Limitations:
#   - Currently supports only Log Analytics workspace destinations
#   - Does not support Storage Account or Event Hub destinations
#   - Does not support partner solutions destinations
#   - Lifecycle ignore_changes on log_analytics_destination_type is a workaround
#     for Azure API/provider inconsistencies
#
# =============================================================================

# =============================================================================
# Section: Local Values
# =============================================================================

locals {
  # Filter and organize monitored services with their log categories
  # For each service, extract only the log categories that match the include filter
  # If include is empty, all log categories are selected
  # Use try() to handle cases where logs attribute doesn't exist (e.g., Log Analytics Workspaces)
  # Only include services that have at least one log category OR at least one metric available
  # This prevents creating diagnostic settings with no enabled logs or metrics (which Azure rejects)
  selected_categories = { for k, v in data.azurerm_monitor_diagnostic_categories.categories :
    k => {
      id    = var.monitored_services[k].id
      table = var.monitored_services[k].table
      logs  = [for l in try(v.logs, []) : l if contains(var.monitored_services[k].include, l) || length(var.monitored_services[k].include) == 0]
    }
    if length([for l in try(v.logs, []) : l if contains(var.monitored_services[k].include, l) || length(var.monitored_services[k].include) == 0]) > 0 || length(try(v.metrics, [])) > 0
  }
}

# =============================================================================
# Section: Data Sources
# =============================================================================

data "azurerm_monitor_diagnostic_categories" "categories" {
  for_each = var.monitored_services

  resource_id = each.value.id
}

# =============================================================================
# Section: Diagnostic Settings
# =============================================================================

resource "azurerm_monitor_diagnostic_setting" "setting" {
  for_each = local.selected_categories

  name                           = "diag-${each.key}"
  target_resource_id             = each.value.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = each.value.table == "None" ? null : each.value.table

  dynamic "enabled_log" {
    for_each = each.value.logs

    content {
      category = enabled_log.value

      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.categories[each.key].metrics

    content {
      category = metric.value
      enabled  = true

      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }

  lifecycle {
    ignore_changes = [
      log_analytics_destination_type # Azure API Bug or maybe TF provider bug
    ]
  }
}