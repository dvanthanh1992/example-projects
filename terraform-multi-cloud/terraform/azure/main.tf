/*
Terraform Microsoft Azure Provider
*/

terraform {
  required_version = ">= 1.8.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.14.0"
    }
  }
}

provider "azurerm" {
  features {  
    key_vault {
      purge_soft_deleted_secrets_on_destroy = true
    }
  }
  subscription_id = var.subscription_id
}

locals {
  resource_prefix                   = var.iij_name_prefix
  service_principal_name            = "${local.resource_prefix}-service-principal"
  key_vault_name                    = "${local.resource_prefix}-kv"
  selenium_address_space            = split(",", replace(replace(var.selenium_address_space, "[", ""), "]", ""))
  selenium_subnet_address_prefixes  = split(",", replace(replace(var.selenium_subnet_address_prefixes, "[", ""), "]", ""))
  list_allow_ip_private_clean       = split(",", replace(replace(replace(var.list_allow_ip_private, "[", ""), "]", ""), "'", ""))
  list_allow_ip_private             = [for ip in local.list_allow_ip_private_clean : trimspace(ip)]
}

data "azuread_client_config" "current" {}

data "azurerm_resource_group" "existing_rg" {
  name                              = var.resource_group_name
}

module "service_principal" {
  source                            = "./modules/service_principal"
  service_principal_name            = local.service_principal_name
}

resource "azurerm_role_assignment" "assign_contributor" {
  scope                             = "/subscriptions/${var.subscription_id}"
  role_definition_name              = "Contributor"
  principal_id                      = module.service_principal.service_principal_object_id
  depends_on                        = [module.service_principal]
}

module "key_vaults" {
  source                            = "./modules/key_vaults"
  key_vault_name                    = local.key_vault_name
  resource_group_name               = data.azurerm_resource_group.existing_rg.name
  resource_group_location           = data.azurerm_resource_group.existing_rg.location
  service_principal_client_id       = module.service_principal.service_principal_client_id
  service_principal_client_secret   = module.service_principal.service_principal_client_secret
  depends_on                        = [azurerm_role_assignment.assign_contributor]
}

module selenium_performance_test {
  source                            = "./modules/selenium"
  iij_name_prefix                   = var.iij_name_prefix
  resource_group_name               = data.azurerm_resource_group.existing_rg.name
  resource_group_location           = data.azurerm_resource_group.existing_rg.location
  selenium_vm_count                 = var.selenium_vm_count
  selenium_ssh_admin_username       = var.ssh_admin_username
  selenium_address_space            = local.selenium_address_space
  selenium_subnet_address_prefixes  = local.selenium_subnet_address_prefixes
  selenium_list_allow_ip            = local.list_allow_ip_private
  depends_on                        = [module.service_principal]
}

module "virtual_network_vpn" {
  source                            = "./modules/virtual_network_vpn"
  iij_name_prefix                   = var.iij_name_prefix
  resource_group_name               = data.azurerm_resource_group.existing_rg.name
  resource_group_location           = data.azurerm_resource_group.existing_rg.location
  azurerm_address_space             = var.azurerm_address_space
  aks_subnet_address_prefixes       = var.aks_subnet_address_prefixes
  vm_subnet_address_prefixes        = var.vm_subnet_address_prefixes
  gateway_subnet_address_prefixes   = var.gateway_subnet_address_prefixes
  onpremise_gateway_public_ip       = var.onpremise_gateway_public_ip
  onpremise_gateway_address_space   = var.onpremise_gateway_address_space
  depends_on                        = [resource.azurerm_role_assignment.assign_contributor]
}
