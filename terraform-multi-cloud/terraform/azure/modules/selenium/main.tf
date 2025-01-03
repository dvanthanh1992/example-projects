locals {
  selenium_resource_prefix          = "${var.iij_name_prefix}-selenium"
  virtual_network_name              = "${local.selenium_resource_prefix}-vnet"
  virtual_network_subnet_name       = "${local.selenium_resource_prefix}-subnet"
  network_security_group_name_ext   = "${local.selenium_resource_prefix}-nsg-external"
  security_rule_allow_in_all        = "Rule-allow-private-selenium-vm"
  security_rule_allow_out_all       = "Rule-allow-selenium-vm-internet"
  selenium_hub_internal_ip          = azurerm_network_interface.create_selenium_external_nic[0].private_ip_address
  selenium_hub_public_ip            = azurerm_public_ip.create_selenium_public_ip[0].ip_address
}

# Virtual Network
resource "azurerm_virtual_network" "create_selenium_vnet" {
  name                = local.virtual_network_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  address_space       = var.selenium_address_space
}

# Subnet
resource "azurerm_subnet" "create_selenium_subnet" {
  name                 = local.virtual_network_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.create_selenium_vnet.name
  address_prefixes     = var.selenium_subnet_address_prefixes
}

# Security Group External
resource "azurerm_network_security_group" "create_selenium_nsg_external" {
  name                = local.network_security_group_name_ext
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  # Allow private connect to AzureVM
  security_rule {
    name                       = local.security_rule_allow_in_all
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = var.selenium_list_allow_ip
    destination_address_prefix = "*"
  }

  # Allow AzureVM go to Internet
  security_rule {
    name                       = local.security_rule_allow_out_all
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = join(",", var.selenium_subnet_address_prefixes)
    destination_address_prefix = "*"
  }
}

# Public IP Addresses
resource "azurerm_public_ip" "create_selenium_public_ip" {
  count               = var.selenium_vm_count
  name                = "${local.selenium_resource_prefix}-public-ip-${count.index}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network External
resource "azurerm_network_interface" "create_selenium_external_nic" {
  count               = var.selenium_vm_count
  name                = "${local.selenium_resource_prefix}-external-nic-${count.index}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.create_selenium_subnet.id
    public_ip_address_id          = azurerm_public_ip.create_selenium_public_ip[count.index].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "null_resource" "run_firewall_update" {
  provisioner "local-exec" {
    command = <<EOT
      bash "${path.root}/../files/update_firewall.sh" $(echo ${join(" ", azurerm_public_ip.create_selenium_public_ip[*].ip_address)})
    EOT
  }

  depends_on = [
    azurerm_public_ip.create_selenium_public_ip,
    azurerm_network_interface.create_selenium_external_nic
  ]
}

# Manages the association between a Network External and a Network Security Group.
resource "azurerm_network_interface_security_group_association" "create_selenium_external_nic_nsg" {
  count                     = var.selenium_vm_count
  network_interface_id      = azurerm_network_interface.create_selenium_external_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.create_selenium_nsg_external.id
}

resource "azurerm_linux_virtual_machine" "create_vm_selenium" {
  count               = var.selenium_vm_count
  name                = tostring(count.index == 0 
                        ? "${local.selenium_resource_prefix}-vm-hub" 
                        : "${local.selenium_resource_prefix}-vm-node-${count.index}")
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  size                = tostring(count.index == 0 
                        ? "Standard_B4als_v2" : "Standard_B2s")

  admin_username = var.selenium_ssh_admin_username
  admin_ssh_key {
    username   = var.selenium_ssh_admin_username
    public_key = file("${path.root}/../files/selenium_key.pub")
  }

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.create_selenium_external_nic[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  connection {
    type        = "ssh"
    user        = var.selenium_ssh_admin_username
    private_key = file("${path.root}/../files/selenium_key")
    host        = azurerm_public_ip.create_selenium_public_ip[count.index].ip_address
  }

  provisioner "file" {
    source      = "${path.root}/../files/selenium.sh"
    destination = "/home/${var.selenium_ssh_admin_username}/selenium.sh"
  }

provisioner "remote-exec" {
  inline = [
    "cat /etc/os-release && uname -a",
    "sudo chmod +x /home/${var.selenium_ssh_admin_username}/selenium.sh",
    "sudo bash /home/${var.selenium_ssh_admin_username}/selenium.sh install ${var.selenium_node_count} ${local.selenium_hub_internal_ip}",
    count.index == 0 
      ? "sudo bash /home/${var.selenium_ssh_admin_username}/selenium.sh hub ${var.selenium_node_count} ${local.selenium_hub_public_ip}" 
      : "sudo bash /home/${var.selenium_ssh_admin_username}/selenium.sh node ${var.selenium_node_count} ${local.selenium_hub_internal_ip}",
    ]
  }
}
