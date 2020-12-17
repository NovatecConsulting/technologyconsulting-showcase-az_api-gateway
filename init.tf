
terraform {
  backend "azurerm" {
    container_name       = "terraformstate"
  }
}

module "platform" {
  source               = "./modules"
  environment          = var.environment
  location             = "westeurope"
}

variable "environment" { }


provider "azurerm" {
    features {}
}
