terraform {
  source = "../../../../modules/azure/resource-group"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  resource_group_name = "rg-dev-platform"
  location            = "Central India"

  tags = {
    Environment = "dev"
    Project     = "platform-engineering"
    Owner       = "devops-team"
  }
}
