# =============================================================================
# Diagnostic Settings Outputs
# =============================================================================

output "diagnostics" {
  description = "Map of all diagnostic settings with their full configuration"
  value       = azurerm_monitor_diagnostic_setting.setting
}

output "diagnostic_setting_ids" {
  description = "Map of diagnostic setting IDs keyed by service name"
  value       = { for k, v in azurerm_monitor_diagnostic_setting.setting : k => v.id }
}

output "diagnostic_setting_names" {
  description = "Map of diagnostic setting names keyed by service name"
  value       = { for k, v in azurerm_monitor_diagnostic_setting.setting : k => v.name }
}

# =============================================================================
# Configuration Summary Outputs
# =============================================================================

output "monitored_services_summary" {
  description = "Summary of monitored services configuration including enabled log categories"
  value = {
    for k, v in local.selected_categories : k => {
      resource_id            = v.id
      enabled_log_count      = length(v.logs)
      enabled_log_categories = v.logs
      destination_table      = v.table
    }
  }
}

output "total_diagnostic_settings" {
  description = "Total number of diagnostic settings configured"
  value       = length(azurerm_monitor_diagnostic_setting.setting)
}
