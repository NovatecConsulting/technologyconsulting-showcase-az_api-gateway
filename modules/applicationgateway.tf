

resource "azurerm_subnet" "example" {
  name                 = "example"
  resource_group_name  = azurerm_resource_group.resourceGroup.name
  virtual_network_name = azurerm_virtual_network.containernetwork.name
  address_prefixes     = ["10.254.5.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "backend-apigw-pip"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

#&nbsp;since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.containernetwork.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.containernetwork.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.containernetwork.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.containernetwork.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.containernetwork.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.containernetwork.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.containernetwork.name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "backend-appgateway"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.example.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 8080
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    ip_addresses =[azurerm_container_group.backend.ip_address]
  }
  probe {

    name = "todosbackendprobe"
    host = "127.0.0.1"
    interval = 30
    timeout = 30
    unhealthy_threshold = 3
    protocol = "http"
    path ="/todos/"

  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = ""
    port                  = 8080
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "todosbackendprobe"
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}