resource "azurerm_virtual_network" "spoke1" {
  name = "10.20.0.0_16"
  address_space = ["10.20.0.0/16"]
  location = "West Central US"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
}

resource "azurerm_subnet" "spoke1subnet" {
  name = "10.20.0.0_24"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
  virtual_network_name = "${azurerm_virtual_network.spoke1.name}"
  address_prefix = "10.20.0.0/24"
  route_table_id = "${azurerm_route_table.spokert.id}" 
}

resource "azurerm_virtual_network_peering" "spoke1tohub" {
  name                      = "spoke1tohub"
  resource_group_name       = "${azurerm_resource_group.hub-spoke.name}"
  virtual_network_name      = "${azurerm_virtual_network.spoke1.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.hub.id}"
  allow_virtual_network_access = true
  allow_gateway_transit        = false
  allow_forwarded_traffic      = true
}

