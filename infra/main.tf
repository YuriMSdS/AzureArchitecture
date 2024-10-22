provider "azurerm" {
  features {}
}

variable "db_password" {
  description = "Senha do administrador do banco de dados"
  type        = string
  sensitive   = true
}

resource "azurerm_resource_group" "architecture_group" {
  name     = "cloud_project"
  location = "Brazil South"
}

resource "azurerm_virtual_network" "virt_network" {
  name                = "vnet1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.architecture_group.location
  resource_group_name = azurerm_resource_group.architecture_group.name
}

resource "azurerm_subnet" "sub_net" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.architecture_group.name
  virtual_network_name = azurerm_virtual_network.virt_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "PubIP" {
  name                = "myPubIP"
  location            = azurerm_resource_group.architecture_group.location
  resource_group_name = azurerm_resource_group.architecture_group.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "NIC" {
  name                = "nic1"
  location            = azurerm_resource_group.architecture_group.location
  resource_group_name = azurerm_resource_group.architecture_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub_net.id
    private_ip_address_allocation  = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.PubIP.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg1"
  location            = azurerm_resource_group.architecture_group.location
  resource_group_name = azurerm_resource_group.architecture_group.name

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.sub_net.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "VM" {
  name                  = "vm1"
  resource_group_name   = azurerm_resource_group.architecture_group.name
  location              = azurerm_resource_group.architecture_group.location
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub") 
  }

  network_interface_ids = [
    azurerm_network_interface.NIC.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_postgresql_server" "postgre_database" {
  name                = "postgre-db-server"
  location            = azurerm_resource_group.architecture_group.location
  resource_group_name = azurerm_resource_group.architecture_group.name

  administrator_login          = "dbadmin"
  administrator_login_password = var.db_password

  sku_name   = "GP_Gen5_2"
  storage_mb = 5120
  version    = "11"
  auto_grow_enabled   = true
  ssl_enforcement_enabled = true
}

resource "azurerm_postgresql_database" "db1" {
  name                = "database_prod"
  resource_group_name = azurerm_resource_group.architecture_group.name
  server_name         = azurerm_postgresql_server.postgre_database.name
  charset             = "UTF8"
  collation           = "Portuguese_Brazil_CI_AS"
}

resource "azurerm_postgresql_firewall_rule" "allow_all_ips" {
  name                = "allow-external-access"
  resource_group_name = azurerm_resource_group.architecture_group.name
  server_name         = azurerm_postgresql_server.postgre_database.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}