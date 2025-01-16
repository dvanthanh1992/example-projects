output "azure_nsg_id" {
  value       = azurerm_network_security_group.create_azure_nsg.id
  description = "Specifies the resource id of the network security group"
}