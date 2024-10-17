

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

data "azurerm_key_vault_secret" "sshpubkey" {
  name      = "sshpubkey"
  key_vault_id = data.azurerm_key_vault.example.id
}

data "azurerm_key_vault_secret" "spnclientid" {
  name      = "spnclientid"
  key_vault_id = data.azurerm_key_vault.example.id
}

data "azurerm_key_vault_secret" "spnclientsecret" {
  name      = "spnclientsecret"
  key_vault_id = data.azurerm_key_vault.example.id
}

resource "azurerm_resource_group" "rg" {
  location = "east us"
  name     = "aks-demo-rg"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = "aks-demo-123"
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-demo-123"


  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = 2
  }

  linux_profile {
    admin_username = "sshuser"

    ssh_key {
      key_data = data.azurerm_key_vault_secret.sshpubkey.value
    }
  }
 
role_based_access_control {
    enabled = true
}

service_principal {
    client_id     = data.azurerm_key_vault_secret.spnclientid.value
    client_secret = data.azurerm_key_vault_secret.spnclientsecret.value
  }

}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config_raw}"
  sensitive = true
}
