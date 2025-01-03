/*  
    Defines the input variables from Key Vault module
*/

variable "key_vault_name" {
  type = string
  description = "Specifies the name of the Key Vault"
}

variable "resource_group_name" {
  type = string
  description = "The name of the resource group in which to create the Key Vault"
}

variable "resource_group_location" {
  type = string
  description = "The supported Azure location where the resource exists"
}

variable "service_principal_client_id" {
  type        = string
  description = "The client ID of the Service Principal used to authenticate Terraform"
}

variable "service_principal_client_secret" {
  type        = string
  description = "The client secret (password) of the Service Principal used to authenticate Terraform"
  sensitive   = true
}
