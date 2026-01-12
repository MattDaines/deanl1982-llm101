output "website_url" {
  description = "URL of the static website"
  value       = azurerm_storage_account.bingo.primary_web_endpoint
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.bingo.name
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.bingo.name
}

output "storage_account_key" {
  description = "Storage account primary access key (sensitive)"
  value       = azurerm_storage_account.bingo.primary_access_key
  sensitive   = true
}
