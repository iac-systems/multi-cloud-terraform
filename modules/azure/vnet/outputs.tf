output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "vnet_cidr" {
  value = var.vnet_cidr
}

output "subnet_ids" {
  value = {
    for k, v in azurerm_subnet.subnets :
    k => v.id
  }
}

output "subnet_cidrs" {
  value = local.calculated_subnets
}
