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

variable "selenium_vm_count" {
  type        = number
  description = "Number of Ubuntu VMs to create"
}

variable "selenium_node_count" {
  type        = string
  description = "The number of Selenium Node containers to be deployed. Each container runs an instance of Selenium Node. Adjust this value to scale the testing infrastructure."
  default     = "2"
}

variable "selenium_address_space" {
  type        = list(string)
  description = "Address space for the Virtual Network"
}

variable "selenium_list_allow_ip" {
  type        = list(string)
  description = "List of IP addresses or CIDR blocks allowed to access to VM"
}

variable "selenium_subnet_address_prefixes" {
  type        = list(string)
  description = "Address prefixes for the Subnet"
}

variable "selenium_ssh_admin_username" {
  type        = string
  description = "The username for SSH administrative access, used for connecting to the server."
}
