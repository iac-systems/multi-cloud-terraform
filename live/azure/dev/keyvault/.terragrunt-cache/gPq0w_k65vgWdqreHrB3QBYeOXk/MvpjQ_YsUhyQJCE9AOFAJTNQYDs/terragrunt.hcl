terraform {
  source = "../../../../modules/azure/keyvault"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "resource_group" {
  config_path = "../resource-group"
}

inputs = {
  resource_group_name = dependency.resource_group.outputs.resource_group_name
  location            = dependency.resource_group.outputs.resource_group_location
  keyvault_name       = "kv-dev-platform-821"
  tenant_id           = "1dcae3d8-0c6c-4900-9405-f07d31cf06a9"
  tags = {
    Environment = "dev"
    Project     = "platform-engineering"
  }
}
