resource "azurerm_key_vault" "key_vault" {
  name                = "keyvault${var.environment}"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  enabled_for_disk_encryption = true

  #Terraform for secret creation
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [ "delete", "get", "set", "list" ]
  }
  # PA TC
  access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = "3f17a18b-59fc-4c13-a6d2-5852c4d8312a" 

  secret_permissions = ["delete", "get", "set", "list"]
  }
}
