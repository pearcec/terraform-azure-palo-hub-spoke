terraform {
  required_version = ">= 0.9.2"
}

provider "azurerm" {
  # https://www.terraform.io/docs/providers/azurerm/index.html#subscription_id
  # Source through environment
}

# Resource group
resource "azurerm_resource_group" "hub-spoke" {
  name     = "sandbox-hub-spoke"
  location = "West US"
}
