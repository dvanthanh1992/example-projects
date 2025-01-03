data "azuread_client_config" "current" {}

# output "all_client_config_data" {
#   value = {
#     tenant_id       = data.azuread_client_config.current.tenant_id
#     client_id       = data.azuread_client_config.current.client_id
#     object_id       = data.azuread_client_config.current.object_id
#   }
# }

resource "azuread_application" "create_azuread_application" {
  display_name = var.service_principal_name
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "create_service_principal" {
  client_id                    = azuread_application.create_azuread_application.client_id
  app_role_assignment_required = true
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "create_service_principal_password" {
  service_principal_id = azuread_service_principal.create_service_principal.id
  end_date             = timeadd(timestamp(), "240h")
}
