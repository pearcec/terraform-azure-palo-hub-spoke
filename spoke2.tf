resource "azurerm_virtual_network" "spoke2" {
  name = "10.30.0.0_16"
  address_space = ["10.30.0.0/16"]
  location = "West Central US"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
}

resource "azurerm_subnet" "spoke2subnet" {
  name = "10.30.0.0_24"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
  virtual_network_name = "${azurerm_virtual_network.spoke2.name}"
  address_prefix = "10.30.0.0/24"
  route_table_id = "${azurerm_route_table.spokert.id}" 
}

resource "azurerm_virtual_network_peering" "spoke2tohub" {
  name                      = "spoke2tohub"
  resource_group_name       = "${azurerm_resource_group.hub-spoke.name}"
  virtual_network_name      = "${azurerm_virtual_network.spoke2.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.hub.id}"
  allow_virtual_network_access = true
  allow_gateway_transit        = false
  allow_forwarded_traffic      = true
}

