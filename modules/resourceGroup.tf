resource "azurerm_resource_group" "resourceGroup" {
        name = "tc-iac-${var.environment}"
        location = var.location
}
