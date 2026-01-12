variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-ai-bingo"
}

variable "location" {
  description = "Azure region for resources (must support Static Web Apps: westus2, centralus, eastus2, westeurope, eastasia)"
  type        = string
  default     = "eastus2"
}

variable "app_name" {
  description = "Name of the Static Web App"
  type        = string
  default     = "ai-bingo-game"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "production"
}
