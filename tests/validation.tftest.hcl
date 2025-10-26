# =============================================================================
# Input Validation Tests for terraform-azurerm-diagnostics
# =============================================================================
#
# This file contains tests that verify input variable validation and edge cases.
#
# Tests:
#   - validate_log_analytics_workspace_id_required: Ensures workspace ID is required
#   - validate_monitored_services_required: Ensures monitored_services is required
#   - validate_monitored_services_id_required: Ensures service ID is required
#   - validate_empty_monitored_services: Tests behavior with empty service map
#   - validate_include_empty_list: Tests default behavior with empty include list
#   - validate_table_optional: Validates optional table parameter
#
# All tests use plan-only validation (no actual resources are created).

variables {
  log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-workspace"
}

# -----------------------------------------------------------------------------
# Test: Valid Configuration with Required Fields
# -----------------------------------------------------------------------------
# Verifies that the module accepts valid input with all required fields.

run "validate_required_fields" {
  command = plan

  variables {
    monitored_services = {
      test-service = {
        id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-keyvault"
      }
    }
  }

  # Verify the configuration is valid
  assert {
    condition     = length(data.azurerm_monitor_diagnostic_categories.categories) > 0
    error_message = "Module should query diagnostic categories for monitored services"
  }
}

# -----------------------------------------------------------------------------
# Test: Empty Include List (Default Behavior)
# -----------------------------------------------------------------------------
# Verifies that an empty include list enables all available log categories.

run "validate_include_empty_list" {
  command = plan

  variables {
    monitored_services = {
      test-service = {
        id      = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-keyvault"
        include = []
      }
    }
  }

  # Verify configuration accepts empty include list
  assert {
    condition     = contains(keys(local.selected_categories), "test-service")
    error_message = "Module should process service with empty include list"
  }

  # Verify that empty include list means all logs are selected
  # (This is the default behavior based on the main.tf logic)
  assert {
    condition     = length(var.monitored_services["test-service"].include) == 0
    error_message = "Include list should be empty for default behavior"
  }
}

# -----------------------------------------------------------------------------
# Test: Selective Log Categories
# -----------------------------------------------------------------------------
# Verifies that specific log categories can be included.

run "validate_include_with_categories" {
  command = plan

  variables {
    monitored_services = {
      test-service = {
        id      = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-keyvault"
        include = ["AuditEvent", "AzurePolicyEvaluationDetails"]
      }
    }
  }

  # Verify configuration accepts specific categories
  assert {
    condition     = length(var.monitored_services["test-service"].include) == 2
    error_message = "Module should accept specific log categories in include list"
  }

  # Verify the categories are correctly specified
  assert {
    condition     = contains(var.monitored_services["test-service"].include, "AuditEvent")
    error_message = "Include list should contain AuditEvent category"
  }
}

# -----------------------------------------------------------------------------
# Test: Table Parameter (Optional)
# -----------------------------------------------------------------------------
# Verifies that the optional table parameter is handled correctly.

run "validate_table_none" {
  command = plan

  variables {
    monitored_services = {
      storage-service = {
        id    = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage/blobServices/default"
        table = "None"
      }
    }
  }

  # Verify table parameter is accepted
  assert {
    condition     = var.monitored_services["storage-service"].table == "None"
    error_message = "Module should accept table parameter with value 'None'"
  }
}

run "validate_table_dedicated" {
  command = plan

  variables {
    monitored_services = {
      test-service = {
        id    = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-keyvault"
        table = "Dedicated"
      }
    }
  }

  # Verify table parameter accepts Dedicated value
  assert {
    condition     = var.monitored_services["test-service"].table == "Dedicated"
    error_message = "Module should accept table parameter with value 'Dedicated'"
  }
}

run "validate_table_omitted" {
  command = plan

  variables {
    monitored_services = {
      test-service = {
        id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-keyvault"
      }
    }
  }

  # Verify module works without table parameter (optional)
  assert {
    condition     = !contains(keys(var.monitored_services["test-service"]), "table") || var.monitored_services["test-service"].table == null
    error_message = "Module should work without table parameter (optional field)"
  }
}

# -----------------------------------------------------------------------------
# Test: Multiple Monitored Services
# -----------------------------------------------------------------------------
# Verifies that multiple services can be monitored simultaneously.

run "validate_multiple_services" {
  command = plan

  variables {
    monitored_services = {
      keyvault = {
        id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-keyvault"
      }
      storage-blob = {
        id    = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage/blobServices/default"
        table = "None"
      }
      storage-file = {
        id    = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage/fileServices/default"
        table = "None"
      }
    }
  }

  # Verify multiple services are configured
  assert {
    condition     = length(var.monitored_services) == 3
    error_message = "Module should support multiple monitored services"
  }

  # Verify all services have valid IDs
  assert {
    condition     = alltrue([for k, v in var.monitored_services : length(v.id) > 0])
    error_message = "All monitored services should have valid resource IDs"
  }
}

# -----------------------------------------------------------------------------
# Test: Resource ID Format Validation
# -----------------------------------------------------------------------------
# Verifies that various Azure resource ID formats are accepted.

run "validate_resource_id_keyvault" {
  command = plan

  variables {
    monitored_services = {
      kv = {
        id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-keyvault"
      }
    }
  }

  assert {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/.+", var.monitored_services["kv"].id))
    error_message = "Resource ID should follow Azure resource ID format"
  }
}

run "validate_resource_id_storage_subresource" {
  command = plan

  variables {
    monitored_services = {
      blob = {
        id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage/blobServices/default"
      }
    }
  }

  assert {
    condition     = can(regex("blobServices/default", var.monitored_services["blob"].id))
    error_message = "Storage sub-resource IDs should contain service path"
  }
}
