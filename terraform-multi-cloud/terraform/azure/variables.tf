/*  
    Defines the input variables from Terraform Azure
*/

variable "subscription_id" {
  type        = string
  description = "The subscription ID of the Azure account"
}

variable "iij_name_prefix" {
  type        = string
  description = "Prefix for Azure resources"
}

variable "resource_group_name" {
  type        = string
  description = "The supported Azure name which should be used for this Resource Group."
}

variable "ssh_admin_username" {
  type        = string
  description = "The username for SSH administrative access, used for connecting to the server."
}

variable "list_allow_ip_private" {
  description = "List of IP addresses or CIDR blocks allowed to access to VM"
}

variable "selenium_vm_count" {
  type        = number
  description = "Number of Ubuntu VMs to create"
}

variable "selenium_address_space" {
  description = "Address space for the Virtual Network"
}

variable "selenium_subnet_address_prefixes" {
  description = "Address prefixes for the Subnet"
}


################################################

variable "subscription_id" {
  type        = string
  description = "The subscription ID of the Azure account"
}

variable "iij_name_prefix" {
  type        = string
  description = "Prefix for Azure resources"
}

variable "resource_group_name" {
  type        = string
  description = "The supported Azure name which should be used for this Resource Group."
}

variable "ssh_admin_username" {
  type        = string
  description = "The username for SSH administrative access, used for connecting to the server."
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

variable "list_allow_ip_private" {
  type        = list(string)
  description = "List of IP addresses or CIDR blocks that are allowed to access the VMs privately, typically used for internal traffic or specific clients."
}
