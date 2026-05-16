# Azure Storage Account for AI Energy Mobility Platform
# NOTE: This is design-only - DO NOT APPLY to avoid billing
# This demonstrates production-grade cloud architecture knowledge

resource "random_id" "storage_suffix" {
  byte_length = 4
}

resource "azurerm_storage_account" "aem_storage" {
  name                     = "aemstorage${var.environment}${random_id.storage_suffix.hex}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = {
    project     = var.project_name
    environment = var.environment
    purpose     = "ai-energy-mobility-lakehouse"
  }
}

# Lakehouse container structure
resource "azurerm_storage_container" "raw" {
  name                  = "aem-raw"
  storage_account_name  = azurerm_storage_account.aem_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "processed" {
  name                  = "aem-processed"
  storage_account_name  = azurerm_storage_account.aem_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "analytics" {
  name                  = "aem-analytics"
  storage_account_name  = azurerm_storage_account.aem_storage.name
  container_access_type = "private"
}

# Azure Event Hubs for streaming (design-only)
resource "azurerm_eventhub_namespace" "aem_events" {
  name                = "aem-events-${var.environment}-${random_id.storage_suffix.hex}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  
  tags = {
    project     = var.project_name
    environment = var.environment
    purpose     = "streaming-backbone"
  }
}

# Output Azure resource information for reference
output "storage_account_name" {
  description = "Name of the Azure Storage Account"
  value       = azurerm_storage_account.aem_storage.name
}

output "storage_account_id" {
  description = "ID of the Azure Storage Account"
  value       = azurerm_storage_account.aem_storage.id
}

output "raw_container_name" {
  description = "Name of the raw data container"
  value       = azurerm_storage_container.raw.name
}

output "processed_container_name" {
  description = "Name of the processed data container"
  value       = azurerm_storage_container.processed.name
}

output "analytics_container_name" {
  description = "Name of the analytics container"
  value       = azurerm_storage_container.analytics.name
}

output "eventhub_namespace_name" {
  description = "Name of the Event Hubs namespace"
  value       = azurerm_eventhub_namespace.aem_events.name
}