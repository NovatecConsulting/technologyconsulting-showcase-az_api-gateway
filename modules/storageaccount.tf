resource "azurerm_storage_account" "storage_account" {
    name = "storageacc${var.environment}"
    location = azurerm_resource_group.resourceGroup.location
    resource_group_name = azurerm_resource_group.resourceGroup.name
    account_kind = "StorageV2"
    account_tier = "Standard"
    account_replication_type = "LRS" // Since this is just a demo and we're not working with important data, LRS should be enough
}

resource "azurerm_storage_container" "storage_container_common" {
    name = "commonstorage"
    storage_account_name = azurerm_storage_account.storage_account.name
    container_access_type = "private"
}
