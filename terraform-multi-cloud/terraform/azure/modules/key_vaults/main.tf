data "azuread_client_config" "current" {}

resource "azurerm_key_vault" "create_key_vault" {
  name                       = var.key_vault_name
  resource_group_name        = var.resource_group_name
  location                   = var.resource_group_location
  tenant_id                  = data.azuread_client_config.current.tenant_id
  sku_name                   = "standard"
  enable_rbac_authorization  = false
  access_policy {
    tenant_id = data.azuread_client_config.current.tenant_id
    object_id = data.azuread_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Import",
      "Update",
      "Verify",
      "Decrypt",
      "Encrypt",
      "Purge",
      "Delete",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "List",
      "Purge",
      "Delete",
    ]
  }
}

resource "azurerm_key_vault_secret" "service_principal_client_secret" {
  name         = var.service_principal_client_id
  value        = var.service_principal_client_secret
  key_vault_id = azurerm_key_vault.create_key_vault.id
}
