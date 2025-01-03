output "selenium_virtual_network" {
  value = {
    name                    = azurerm_virtual_network.create_selenium_vnet.name
    address_space           = azurerm_virtual_network.create_selenium_vnet.address_space
  }
}

output "selenium_subnet" {
  value = {
    name                    = azurerm_subnet.create_selenium_subnet.name
    address_prefixes        = azurerm_subnet.create_selenium_subnet.address_prefixes
  }
}

output "selenium_senetwork_security_group" {
  value = {
    name                        = azurerm_network_security_group.create_selenium_nsg_external.name
    security_rule_allow_in_all  = local.security_rule_allow_in_all
    source_address_prefixes     = var.selenium_list_allow_ip
    security_rule_allow_out_all = local.security_rule_allow_out_all
    source_address_prefix       = join(",", var.selenium_subnet_address_prefixes)
  }
}

output "information_of_selenium_vms" {
  value = [
    for idx in range(var.selenium_vm_count) : {
      vm_name               = azurerm_linux_virtual_machine.create_vm_selenium[idx].name
      public_ip             = azurerm_public_ip.create_selenium_public_ip[idx].ip_address
      private_ip            = azurerm_network_interface.create_selenium_external_nic[idx].private_ip_address
      external_nic_name     = azurerm_network_interface.create_selenium_external_nic[idx].name
    }
  ]
}
