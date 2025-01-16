/*  
    Defines the input variables from Selenium Test module
*/

variable "iij_name_prefix" {
  type        = string
  description = "Prefix for Azure resources"
}

variable "resource_group_name" {
  type = string
  description = "The name of the resource group in which to create the Key Vault"
}

variable "resource_group_location" {
  type        = string
  description = "The supported Azure location where the resource exists"
}

variable "azurerm_address_space" {
  type        = list(string)
  description = "Address space for the Virtual Network. This defines the overall IP range that will be used to allocate subnets for AKS, VMs, and Gateway."
}

variable "aks_subnet_address_prefixes" {
  type        = list(string)
  description = "Address prefixes for the Kubernetes cluster subnet. This subnet will host all the pods and services within the AKS cluster."
}

variable "vm_subnet_address_prefixes" {
  type        = list(string)
  description = "Address prefixes for the VM subnet. This subnet is used to host virtual machines that need to connect to AKS or other resources within the virtual network."
}

variable "gateway_subnet_address_prefixes" {
  type        = list(string)
  description = "Address prefixes for the Gateway subnet. This subnet is dedicated to VPN Gateway or ExpressRoute Gateway connections for secure external access."
}

variable "onpremise_gateway_address_space" {
  type        = list(string)
  description = "The address space of the on-premise network. This is used to define the IP range that is allowed to communicate with the Azure Virtual Network."
}

variable "onpremise_gateway_public_ip" {
  type        = string
  description = "The public IP address of the on-premise VPN Gateway. This is used to establish a secure connection between the on-premise network and the Azure Virtual Network."
}
