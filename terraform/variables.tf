variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-ai-bingo"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique, 3-24 lowercase letters and numbers)"
  type        = string
  default     = "aibingostorage"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "production"
}
