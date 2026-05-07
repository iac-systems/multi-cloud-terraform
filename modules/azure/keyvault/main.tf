data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                        = var.keyvault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = var.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "Create", "Delete", "List",
    ]

    secret_permissions = [
      "Get", "Set", "Delete", "List",
    ]

    storage_permissions = [
      "Get",
    ]
  }

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "aks" {
  count        = var.aks_identity_object_id != null ? 1 : 0
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenant_id
  object_id    = var.aks_identity_object_id

  secret_permissions = [
    "Get", "List",
  ]
}
