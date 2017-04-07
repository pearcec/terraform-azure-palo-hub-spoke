# By default we do not build the palo machine.
# The resource group and storage account needs built first.

variable "build_palo_machine" {
  default = 0
  description = "Skip building palo machine"
}

resource "azurerm_public_ip" "palopublicip" {
  name = "palo-public-ip"
  location = "West Central US"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
  public_ip_address_allocation = "dynamic"
}

resource "azurerm_network_interface" "trust" {
  name = "hub-trust-eth0"
  location = "West Central US"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"

  ip_configuration {
    name = "ipconfig-trust"
    subnet_id = "${azurerm_subnet.trust.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_interface" "untrust" {
  name = "hub-untrust-eth0"
  location = "West Central US"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"

  ip_configuration {
    name = "ipconfig-unstrust"
    subnet_id = "${azurerm_subnet.untrust.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_interface" "mgmt" {
  name = "hub-mgmt-eth0"
  location = "West Central US"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"

  ip_configuration {
    name = "ipconfig-mgmt"
    subnet_id = "${azurerm_subnet.mgmt.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id  = "${azurerm_public_ip.palopublicip.id}"
  }
}

resource "azurerm_virtual_machine" "palo" {
  count = "${var.build_palo_machine}"
  name = "palo"
  location = "West Central US"
  resource_group_name = "${azurerm_resource_group.hub-spoke.name}"
  vm_size = "Standard_D3_v2"

  network_interface_ids = [
    "${azurerm_network_interface.mgmt.id}",
    "${azurerm_network_interface.untrust.id}",
    "${azurerm_network_interface.trust.id}"
  ]
  primary_network_interface_id = "${azurerm_network_interface.mgmt.id}"

  storage_image_reference {
    publisher = "paloaltonetworks"
    offer = "vmseries1"
    sku = "byol"
    version = "latest"
  }

  plan {
    name = "byol"
    product = "vmseries1"
    publisher = "paloaltonetworks"
  }

  storage_os_disk {
    name = "palo"
    vhd_uri = "${azurerm_storage_account.palostorage.primary_blob_endpoint}${azurerm_storage_container.vhds.name}/palo.vhd"
    caching = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name = "palo"
    admin_username = "paloadmin"
    admin_password = "P1ck_something!"
  }
}
