resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-hub"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "vpn-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.vpn_subnet_prefix
}

resource "azurerm_subnet" "routeserver" {
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.routeserver_subnet_prefix
}

# Azure Route Server
resource "azurerm_public_ip" "rs_pip" {
  name                = "rs-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_route_server" "rs" {
  name                             = "azure-route-server"
  resource_group_name              = azurerm_resource_group.rg.name
  location                         = azurerm_resource_group.rg.location
  sku                              = "Standard"
  public_ip_address_id             = azurerm_public_ip.rs_pip.id
  subnet_id                        = azurerm_subnet.routeserver.id
  branch_to_branch_traffic_enabled = true
}

# Networking for VM
resource "azurerm_network_security_group" "nsg" {
  name                = "vpn-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "ipsec" {
  name                        = "allow-ipsec"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["500", "4500"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_public_ip" "vm_pip" {
  name                = "vpn-vm-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  name                = "vpn-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Static" # Static IP for BGP peering
    private_ip_address            = var.azure_bgp_ip
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# VM Resource
resource "azurerm_linux_virtual_machine" "vpn_vm" {
  name                = "vpn-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v5"
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(
    templatefile("${path.module}/cloud-init.tpl", {
      azure_bgp_asn   = var.azure_bgp_asn
      azure_bgp_ip    = var.azure_bgp_ip
      aws_peer_bgp_ip = var.aws_peer_bgp_ip
      vnet_cidr       = var.vnet_address_space[0]
      azure_public_ip = azurerm_public_ip.vm_pip.ip_address
      aws_peer_ip     = var.aws_peer_ip
      shared_key      = var.shared_key
    })
  )
}

# Route Server BGP Peer
resource "azurerm_route_server_bgp_connection" "frr_peer" {
  name            = "frr-peer"
  route_server_id = azurerm_route_server.rs.id
  peer_asn        = var.azure_bgp_asn
  peer_ip         = var.azure_bgp_ip
}
