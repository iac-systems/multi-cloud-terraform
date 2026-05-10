output "hub_vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vpn_vm_public_ip" {
  value = azurerm_public_ip.vm_pip.ip_address
}

output "route_server_public_ip" {
  value = azurerm_public_ip.rs_pip.ip_address
}

output "vpn_vm_private_ip" {
  value = azurerm_network_interface.nic.private_ip_address
}
