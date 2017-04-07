resource "azurerm_virtual_network" "hub" {
  name = "10.10.0.0_16"
  address_space = ["10.10.0.0/16"]
  location = "West Central US"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
}

resource "azurerm_subnet" "mgmt" {
  name = "Mgmt"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
  virtual_network_name = "${azurerm_virtual_network.hub.name}"
  address_prefix = "10.10.0.0/24"
}

resource "azurerm_subnet" "untrust" {
  name = "Untrust"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
  virtual_network_name = "${azurerm_virtual_network.hub.name}"
  address_prefix = "10.10.1.0/24"
}

resource "azurerm_subnet" "trust" {
  name = "Trust"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
  virtual_network_name = "${azurerm_virtual_network.hub.name}"
  address_prefix = "10.10.2.0/24"
}

resource "azurerm_network_security_group" "mgmtsg" {
    name = "hub-spoke-mgmt-sg"
    location = "West Central US"
    resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
}

resource "azurerm_network_security_rule" "mgmtsgrulein1" {
    name = "Allow-Outside-From-IP"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "0.0.0.0/0"
    destination_address_prefix = "*"
    resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
    network_security_group_name = "${azurerm_network_security_group.mgmtsg.name}"
}

resource "azurerm_network_security_rule" "mgmtsgrulein2" {
    name = "Allow intra network traffic"
    priority = 101
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "10.10.0.0/16"
    destination_address_prefix = "*"
    resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
    network_security_group_name = "${azurerm_network_security_group.mgmtsg.name}"
}

resource "azurerm_network_security_rule" "mgmtsgrulein3" {
    name = "Default-Deny if we don't match Allow rule"
    priority = 200
    direction = "Inbound"
    access = "Deny"
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
    network_security_group_name = "${azurerm_network_security_group.mgmtsg.name}"
}

resource "azurerm_virtual_network_peering" "hubtospoke1" {
  name                      = "hubtospoke1"
  resource_group_name       = "${azurerm_resource_group.hub-spoke.name}"
  virtual_network_name      = "${azurerm_virtual_network.hub.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.spoke1.id}"
  allow_virtual_network_access = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "hubtospoke2" {
  name                      = "hubtospoke2"
  resource_group_name       = "${azurerm_resource_group.hub-spoke.name}"
  virtual_network_name      = "${azurerm_virtual_network.hub.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.spoke2.id}"
  allow_virtual_network_access = true
  allow_gateway_transit        = false
}

# Generic Route table for hauling traffice back to the hub
resource "azurerm_route_table" "spokert" {
  name = "spoke"
  location = "West Central US"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
}

resource "azurerm_route" "spokertroute1" {
  name = "backhaul to hub"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
  route_table_name = "${azurerm_route_table.spokert.name}"

  address_prefix = "0.0.0.0/0"
  next_hop_type = "VirtualAppliance"
  next_hop_in_ip_address = "${azurerm_network_interface.trust.private_ip_address}"
}

resource "azurerm_subnet" "gatewaysubnet" {
  name = "GatewaySubnet"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
  virtual_network_name = "${azurerm_virtual_network.hub.name}"
  address_prefix = "10.10.10.0/29"
}
