terraform {
  source = "../../../../modules/azure/vnet"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {

  resource_group_name = "rg-stg-platform"

  location = "Central India"

  environment = "stg"

  vnet_name = "vnet-stg-platform"

  vnet_cidr = "10.20.0.0/16"

  tags = {
    Environment = "stg"
    Project     = "platform-engineering"
    Owner       = "devops-team"
  }
}
