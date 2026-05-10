terraform {
  source = "../../../../modules/azure/hub-vpn"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  location            = "East US"
  resource_group_name = "rg-dev-hub-vpn"

  azure_bgp_asn   = 65020
  azure_bgp_ip    = "10.100.1.4"
  aws_peer_ip     = "1.2.3.4"      # Placeholder: Replace with actual AWS VPN Public IP
  aws_peer_bgp_ip = "169.254.0.1"  # Placeholder: Replace with actual AWS BGP IP
  shared_key      = "ExampleKey123" # Placeholder: Replace with actual IPSec PSK

  admin_username      = "azureuser"
  ssh_public_key_path = "~/.ssh/id_rsa.pub"

  vnet_address_space        = ["10.100.0.0/16"]
  vpn_subnet_prefix         = ["10.100.1.0/24"]
  routeserver_subnet_prefix = ["10.100.255.0/27"]

  tags = {
    Environment = "dev"
    Project     = "multi-cloud-networking"
    Owner       = "devops-team"
  }
}
