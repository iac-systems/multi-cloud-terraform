terraform {
  source = "../../../../modules/azure/vnet"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "resource_group" {
  config_path = "../resource-group"
}

inputs = {

  resource_group_name = dependency.resource_group.outputs.resource_group_name

  location = dependency.resource_group.outputs.resource_group_location

  environment = "dev"

  vnet_name = "vnet-dev-platform"

  vnet_cidr = "10.10.0.0/16"

  tags = {
    Environment = "dev"
    Project     = "platform-engineering"
    Owner       = "devops-team"
  }
}
