data "azurerm_client_config" "current" {
}

data "azurerm_key_vault" "example" {
  name                = "aks-kv-devops"
  resource_group_name = "aks-kv-rg"
}

resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = data.azurerm_key_vault.example.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
  ]
}


