output "key_vault_name" {
  description = "Specifies the name of the Key Vault. The name must be globally unique"
  value       = azurerm_key_vault.create_key_vault.name
}

output "id_kv_sp_client_secret" {
  description = " The ID of the Key Vault where the Secret should be created."
  value       = azurerm_key_vault_secret.service_principal_client_secret.key_vault_id
}
