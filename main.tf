terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.76.0"
    }
  }
}

#Configurando Microsoft provider

provider "azurerm" {
  features {
  }
  subscription_id = var.subscription_id
}

#Creando un resource group 
resource "azurerm_resource_group" "project1" {
  name     = "Learning-Terraform"
  location = "East Us"
  tags     = { "Environment" = "dev" }
}

#Creando virtual networks de la parte web
resource "azurerm_virtual_network" "project1vnetweb" {
  name                = "vnetweb"
  resource_group_name = azurerm_resource_group.project1.name
  location            = azurerm_resource_group.project1.location
  address_space       = ["192.168.0.0/24"]
  tags                = { "Enviroment" = "dev" }
}

#Creando la subnet donde pertenece la parte web
resource "azurerm_subnet" "project1vnetweb1" {
  name                 = "defaultvnetweb"
  resource_group_name  = azurerm_resource_group.project1.name
  virtual_network_name = azurerm_virtual_network.project1vnetweb.name
  address_prefix       = "192.168.1.0/24"
}
#creando la NIC 
resource "azurerm_network_interface" "project1vnetweb" {
  name                = "vnet_web_interface1"
  location            = azurerm_resource_group.project1.location
  resource_group_name = azurerm_resource_group.project1.name
  ip_configuration {
    name                          = "vnetweb"
    subnet_id                     = azurerm_subnet.project1vnetweb1.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "192.168.0.10"
  }
}

# Creando virtual network para el backend
resource "azurerm_virtual_network" "project1vnetbackend" {
  name                = "vnetbackend"
  resource_group_name = azurerm_resource_group.project1.name
  location            = azurerm_resource_group.project1.location
  address_space       = ["172.16.0.0/16"]
  tags                = { "Enviroment" = "dev" }
}

#Creando la subnet donde pertenece la parte del manager (backend)
resource "azurerm_subnet" "project1vnetbackend1" {
  name                 = "defaultbackend"
  resource_group_name  = azurerm_resource_group.project1.name
  virtual_network_name = azurerm_virtual_network.project1vnetweb.name
  address_prefix       = "172.16.0.0/21"
}

#Creando la NIC
resource "azurerm_network_interface" "project1vnetbackend" {
  name                = "vnet_backend_interface1"
  location            = azurerm_resource_group.project1.location
  resource_group_name = azurerm_resource_group.project1.name
  ip_configuration {
    name                          = "vnetbackend"
    subnet_id                     = azurerm_subnet.project1vnetbackend1.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "172.16.0.10"
  }
}
# Creando la Virtual Network del NVA y el vpn gateway
resource "azurerm_virtual_network" "project1nva" {
  name                = "vnetnva"
  resource_group_name = azurerm_resource_group.project1.name
  location            = azurerm_resource_group.project1.location
  address_space       = ["10.0.0.0/16"]
  tags                = { "Enviroment" = "dev" }
}
#Creando la subred 
resource "azurerm_subnet" "project1nva1" {
  name                 = "defaultnva"
  resource_group_name  = azurerm_resource_group.project1.name
  virtual_network_name = azurerm_virtual_network.project1nva.name
  address_prefix       = "10.0.0.0/21"
}

#Creando la interfaz NIC
resource "azurerm_network_interface" "project1vnetnva" {
  name                = "vnet_nva_interface1"
  resource_group_name = azurerm_resource_group.project1.name
  location            = azurerm_resource_group.project1.location
  ip_configuration {
    name                          = "vnetnva"
    subnet_id                     = azurerm_subnet.project1nva1.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.0.10"
  }
}

#creating NSG for vnetweb
resource "azurerm_network_security_group" "vnetweb" {
  name                = "NSG_vnetweb1"
  location            = azurerm_resource_group.project1.location
  resource_group_name = azurerm_resource_group.project1.name

  #Defining Security Rules

}

# Asociar NSG a web vnet
resource "azurerm_subnet_network_security_group_association" "vnetweb1" {
  subnet_id                 = azurerm_subnet.project1vnetweb1.id
  network_security_group_id = azurerm_network_security_group.vnetweb.id
}

# Creating NSG for vnetbackend
resource "azurerm_network_security_group" "vnetbackend" {
  name                = "NSG_vnetbackend1"
  location            = azurerm_resource_group.project1.location
  resource_group_name = azurerm_resource_group.project1.name

  #Defining Security Rules
}

#Asociar NSG a backend subnet
resource "azurerm_subnet_network_security_group_association" "vnetbackend1" {
  subnet_id                 = azurerm_subnet.project1vnetbackend1.id
  network_security_group_id = azurerm_network_security_group.vnetbackend.id
}

# Creating a NSG for vnetnva
resource "azurerm_network_security_group" "vnetnva1" {
  name                = "NSG_vnetbackend1"
  location            = azurerm_resource_group.project1.location
  resource_group_name = azurerm_resource_group.project1.name

  #Defining Security Rules
}

#asociar NSG a nva subnet
resource "azurerm_subnet_network_security_group_association" "vnetnva1" {
  subnet_id                 = azurerm_subnet.project1nva1.id
  network_security_group_id = azurerm_network_security_group.vnetnva1.id
}

#Creando la tabla de enrutamiento y rutas
resource "azurerm_route_table" "routingtable1" {
  name                = "routingtable"
  location            = azurerm_resource_group.project1.location
  resource_group_name = azurerm_resource_group.project1.name
}

resource "azurerm_route" "route_1" {
  name                = "vnetweb-to-backend"
  resource_group_name = azurerm_resource_group.project1.name
  route_table_name    = azurerm_route_table.routingtable1.name
  address_prefix      = "192.168.1.0/24"
  next_hop_type       = "VirtualAppliance"
}

resource "azurerm_route" "route_2" {
  name                = "backend-to-web"
  resource_group_name = azurerm_resource_group.project1.name
  route_table_name    = azurerm_route_table.routingtable1.name
  address_prefix      = "172.16.0.0/21"
  next_hop_type       = "VirtualAppliance"
}

#Asociando la tabla de enrutamiento a la subred web
resource "azurerm_subnet_route_table_association" "subnetweb1" {
  subnet_id      = azurerm_subnet.project1vnetweb1.id
  route_table_id = azurerm_route_table.routingtable1.id
}
#Asociando la tabla de enrutamiento a la subred backend
resource "azurerm_subnet_route_table_association" "subnetbackend1" {
  subnet_id      = azurerm_subnet.project1nva1.id
  route_table_id = azurerm_route_table.routingtable1.id
}
#Asociando la tabla de enrutamiento a la subred nva
resource "azurerm_subnet_route_table_association" "subnetnva1" {
  subnet_id      = azurerm_subnet.project1nva1.id
  route_table_id = azurerm_route_table.routingtable1.id
}

#Creando un private dns 
resource "azurerm_private_dns_zone" "PrivateDns" {
  name                = "jtesting.net"
  resource_group_name = azurerm_resource_group.project1.name
}

#Creando el link 
resource "azurerm_private_dns_zone_virtual_network_link" "vnetweb" {
  name                  = "vnetweb_link"
  resource_group_name   = azurerm_resource_group.project1.name
  private_dns_zone_name = azurerm_private_dns_zone.PrivateDns.name
  virtual_network_id    = azurerm_virtual_network.project1vnetweb.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetbackend" {
  name                  = "vnetbackend_link"
  resource_group_name   = azurerm_resource_group.project1.name
  private_dns_zone_name = azurerm_private_dns_zone.PrivateDns.name
  virtual_network_id    = azurerm_virtual_network.project1vnetbackend.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetnva" {
  name                  = "vnetnva_link"
  resource_group_name   = azurerm_resource_group.project1.name
  private_dns_zone_name = azurerm_private_dns_zone.PrivateDns.name
  virtual_network_id    = azurerm_virtual_network.project1vnetweb.id
}
