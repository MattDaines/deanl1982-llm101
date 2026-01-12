terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "bingo" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "AI-Bingo-Game"
  }
}

# Storage Account for Static Website
resource "azurerm_storage_account" "bingo" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.bingo.name
  location                 = azurerm_resource_group.bingo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  static_website {
    index_document = "index.html"
  }

  tags = {
    Environment = var.environment
    Project     = "AI-Bingo-Game"
  }
}
