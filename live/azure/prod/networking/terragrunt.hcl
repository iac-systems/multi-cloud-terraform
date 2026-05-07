terraform {
  source = "../../../../modules/azure/vnet"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {

  resource_group_name = "rg-prod-platform"

  location = "Central India"

  environment = "prod"

  vnet_name = "vnet-prod-platform"

  vnet_cidr = "10.30.0.0/16"

  tags = {
    Environment = "prod"
    Project     = "platform-engineering"
    Owner       = "devops-team"
  }
}
