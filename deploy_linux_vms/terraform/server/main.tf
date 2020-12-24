provider "azurerm" {
    features {
    
    }
  
}
resource "azurerm_resource_group" "main" {
    name  =   "${var.prefix}-resources"
    location = var.location
    tags = {
      "env" = var.tag_env,
      "task" = var.tag_task
    }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = azurerm_resource_group.main.tags
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

}
resource "azurerm_network_security_group" "network_security_group" {
  name                = "${var.prefix}-nsg"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = azurerm_resource_group.main.tags
}
resource "azurerm_network_security_rule" "deny_inbound_internet" {
  name                        = "${var.prefix}-deny_inbound_internet"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.network_security_group.name
}
resource "azurerm_network_security_rule" "allow_subnet_traffic" {
  name                        = "${var.prefix}-allow_subnet_traffic"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.network_security_group.name
}

resource "azurerm_network_interface" "main" {
  count               = var.vm_count
  name                = "nic-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = azurerm_resource_group.main.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface_security_group_association" "nic_sec_assoc" {
  count = var.vm_count
  network_interface_id    = azurerm_network_interface.main[count.index].id
  network_security_group_id = azurerm_network_security_group.network_security_group.id
  
}
resource "azurerm_public_ip" "main" {
  name                = "main"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  tags                = azurerm_resource_group.main.tags
}
resource "azurerm_lb" "main" {
  name                = "main"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags = azurerm_resource_group.main.tags
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}
resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "BackEndAddressPool"
}
resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count = var.vm_count
  network_interface_id    = azurerm_network_interface.main[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}
resource "azurerm_availability_set" "avset" {
 name                         = "avset"
 location                     = azurerm_resource_group.main.location
 resource_group_name          = azurerm_resource_group.main.name
 platform_fault_domain_count  = 2
 platform_update_domain_count = 2
 managed                      = true
 tags = azurerm_resource_group.main.tags
}

data "azurerm_image" "packer-image" {
  name                = "packerLinuxImage"
  resource_group_name = "packer-rg"
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.vm_count
  name                            = "${var.prefix}-${count.index}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_A2"
  availability_set_id             = azurerm_availability_set.avset.id
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
  network_interface_ids = [element(azurerm_network_interface.main.*.id, count.index)]
  tags = azurerm_resource_group.main.tags
  source_image_id = data.azurerm_image.packer-image.id
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}