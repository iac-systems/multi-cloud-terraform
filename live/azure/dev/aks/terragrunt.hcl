terraform {
  source = "../../../../modules/azure/aks"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "resource_group" {
  config_path = "../resource-group"
}

dependency "networking" {
  config_path = "../networking"
}

inputs = {
  cluster_name        = "aks-dev-platform"
  location            = dependency.resource_group.outputs.resource_group_location
  resource_group_name = dependency.resource_group.outputs.resource_group_name
  dns_prefix          = "aks-dev"
  
  node_count          = 1
  vm_size             = "Standard_B4s_v2"
  vnet_subnet_id      = dependency.networking.outputs.subnet_ids["aks_nodes"]
  
  network_plugin_mode = "overlay"
  pod_cidr            = "192.168.0.0/16"
  outbound_type       = "userAssignedNATGateway"

  tags = {
    Environment = "dev"
    Project     = "platform-engineering"
    Owner       = "devops-team"
  }
}
