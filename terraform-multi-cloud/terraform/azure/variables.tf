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
