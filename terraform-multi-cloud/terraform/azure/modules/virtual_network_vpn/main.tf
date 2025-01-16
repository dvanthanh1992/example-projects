locals {
  azure_virtual_network_name        = "${var.iij_name_prefix}-vnet" 
  virtual_network_subnet_vm_name    = "${var.iij_name_prefix}-subnet-vm"  
  virtual_network_subnet_aks_name   = "${var.iij_name_prefix}-subnet-aks"
  vpn_public_ip_name                = "${var.iij_name_prefix}-vpn-public-ip"
  vpn_iij_onpremise_name            = "${var.iij_name_prefix}-on-premise-site"
  vpn_gateway_name                  = "${var.iij_name_prefix}-az-vpn-gw"
}

# Azure Virtual Network
resource "azurerm_virtual_network" "create_azure_vnet" {
  name                              = local.azure_virtual_network_name
  location                          = var.resource_group_location
  resource_group_name               = var.resource_group_name
  address_space                     = var.azurerm_address_space
}

# AKS Subnet
resource "azurerm_subnet" "create_aks_subnet" {
  name                              = local.virtual_network_subnet_aks_name
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.create_azure_vnet.name
  address_prefixes                  = var.aks_subnet_address_prefixes
}

# VM Subnet
resource "azurerm_subnet" "create_vm_subnet" {
  name                              = local.virtual_network_subnet_vm_name
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.create_azure_vnet.name
  address_prefixes                  = var.vm_subnet_address_prefixes
}

# Gateway Subnet
resource "azurerm_subnet" "create_vpn_gateway_subnet" {
  name                              = "GatewaySubnet"
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.create_azure_vnet.name
  address_prefixes                  = var.gateway_subnet_address_prefixes
}

# On-premise Local Network Gateway
resource "azurerm_local_network_gateway" "create_onpremise" {
  name                              = local.vpn_iij_onpremise_name
  location                          = var.resource_group_location
  resource_group_name               = var.resource_group_name
  gateway_address                   = var.onpremise_gateway_public_ip
  address_space                     = var.onpremise_gateway_address_space
}

# Azure Public IP Addresses
resource "azurerm_public_ip" "create_vpn_public_ip" {
  name                              = local.vpn_public_ip_name
  location                          = var.resource_group_location
  resource_group_name               = var.resource_group_name
  allocation_method                 = "Static"
  sku                               = "Standard"
}

/*
https://registry.terraform.io/providers/hashicorp/Azurerm/latest/docs/resources/virtual_network_gateway
Please be aware that provisioning a Virtual Network Gateway 
takes a long time (between 30 minutes and 1 hour)
*/

resource "azurerm_virtual_network_gateway" "create_azure_vpn_gateway" {
  name                              = local.vpn_gateway_name
  location                          = var.resource_group_location
  resource_group_name               = var.resource_group_name

  type                              = "Vpn"
  vpn_type                          = "RouteBased"
  sku                               = "VpnGw1"

  active_active                     = false
  enable_bgp                        = false

  ip_configuration {
    subnet_id                       = azurerm_subnet.create_vpn_gateway_subnet.id
    public_ip_address_id            = azurerm_public_ip.create_vpn_public_ip.id
    private_ip_address_allocation   = "Dynamic"
  }
}

# VPN Gateway Connection
resource "azurerm_virtual_network_gateway_connection" "create_connection_to_onpremise" {
  name                              = local.vpn_iij_onpremise_name
  location                          = var.resource_group_location
  resource_group_name               = var.resource_group_name

  type                              = "IPsec"
  virtual_network_gateway_id        = azurerm_virtual_network_gateway.create_azure_vpn_gateway.id
  local_network_gateway_id          = azurerm_local_network_gateway.create_onpremise.id

  shared_key                          = "xxxxxxxx"
  use_policy_based_traffic_selectors  = true
  ipsec_policy{ 
    ike_encryption                    = "AES256"
    ike_integrity                     = "SHA256"
    dh_group                          = "DHGroup2"

    ipsec_encryption                  = "GCMAES256"
    ipsec_integrity                   = "GCMAES256"
    pfs_group                         = "PFS2"

    sa_lifetime                       = 3600
    sa_datasize                       = 27000
  }
}
