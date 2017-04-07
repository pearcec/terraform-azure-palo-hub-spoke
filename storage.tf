# Avoid name collision
resource "random_id" "storage" {
  byte_length = 4
}

resource "azurerm_storage_account" "palostorage" {
  name                = "palostorage${random_id.storage.hex}"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
  location            = "West Central US"
  account_type        = "Standard_LRS"
}
resource "azurerm_storage_container" "vhds" {
  name                  = "vhds"
  resource_group_name   = "${azurerm_resource_group.hub-spoke.name}"
  storage_account_name  = "${azurerm_storage_account.palostorage.name}"
  container_access_type = "private"
}
