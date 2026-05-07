locals {

  subnet_config = {
    aks_nodes = {
      newbits = 4
      netnum  = 0
    }

    aks_pods = {
      newbits = 2
      netnum  = 1
    }

    internal_services = {
      newbits = 8
      netnum  = 128
    }

    private_endpoints = {
      newbits = 8
      netnum  = 129
    }

    ingress = {
      newbits = 8
      netnum  = 130
    }

    bastion = {
      newbits = 10
      netnum  = 524
    }

    monitoring = {
      newbits = 8
      netnum  = 132
    }

    database = {
      newbits = 8
      netnum  = 133
    }
  }

  calculated_subnets = {
    for name, cfg in local.subnet_config :
    name => cidrsubnet(
      var.vnet_cidr,
      cfg.newbits,
      cfg.netnum
    )
  }
}

resource "azurerm_virtual_network" "this" {

  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = [
    var.vnet_cidr
  ]

  tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "vnet"
    },
    var.tags
  )
}

resource "azurerm_subnet" "subnets" {

  for_each = local.calculated_subnets

  name                 = "${var.environment}-${each.key}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [
    each.value
  ]
}

resource "azurerm_public_ip" "nat" {
  name                = "${var.vnet_name}-nat-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "this" {
  name                = "${var.vnet_name}-nat-gw"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "aks_nodes" {
  subnet_id      = azurerm_subnet.subnets["aks_nodes"].id
  nat_gateway_id = azurerm_nat_gateway.this.id
}
