

resource "azurerm_virtual_network" "containernetwork" {
  name                = "container-network"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  address_space       = ["10.254.0.0/16"]
}


resource "azurerm_subnet" "backend" {
  name                 = "backend"
  resource_group_name  = azurerm_resource_group.resourceGroup.name
  virtual_network_name = azurerm_virtual_network.containernetwork.name
  address_prefixes     = ["10.254.1.0/24"]
  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}


resource "azurerm_network_profile" "netprofile" {
  name                = "networkprofile${var.environment}"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  container_network_interface {
    name = "hellocnic"

    ip_configuration {
      name      = "helloipconfig"
      subnet_id = azurerm_subnet.backend.id
    }
  }
}

resource "azurerm_container_group" "database" {
  name                = "database-${var.environment}"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name
  ip_address_type     = "Private"
  network_profile_id  = azurerm_network_profile.netprofile.id
  os_type             = "Linux"
  restart_policy      = "Never"

  container {
    name   = "postgresdb"
    image  = "postgres:latest"
    cpu    = "0.5"
    memory = "1.5"

    
    environment_variables = {
        POSTGRES_PASSWORD="password"
        POSTGRES_USER="matthias"
        POSTGRES_DB="mydb"
    }

     ports {
      port     = 5432
      protocol = "TCP"
    }

  }

  tags = {
    environment = "database"
  }
}

resource "azurerm_container_group" "backend" {
  name                = "backend-${var.environment}"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name
  ip_address_type     = "Private"
  network_profile_id  = azurerm_network_profile.netprofile.id
  os_type             = "Linux"
  restart_policy      = "Never"

container {
    name   = "backend"
    image  = "novatec/technologyconsulting-containerexcerciseapp-todobackend:v0.1"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8080
      protocol = "TCP"
    }
    environment_variables = {
        POSTGRES_HOST=azurerm_container_group.database.ip_address

    }
    
  }
}

resource "azurerm_container_group" "frontend" {
  name                = "frontend-${var.environment}"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name
  ip_address_type     = "public"
  os_type             = "Linux"
  restart_policy      = "Never"

  container {
    name   = "frontend"
    image  = "novatec/technologyconsulting-containerexcerciseapp-todoui:v0.1"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8090
      protocol = "TCP"
    }
    environment_variables = {
        BACKEND_HOST="TODOIPOFBACKENDPUBLIC"
        BACKEND_PORT="8080"
   
    }
  }

  tags = {
    environment = "frontend"
  }
}