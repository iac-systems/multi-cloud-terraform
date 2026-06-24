locals {
  # Parse the cloud provider from the path
  # path_relative_to_include() returns the path from the root root.hcl to the current one
  # Path is usually: live/<cloud>/<env>/<resource>
  path_parts = split("/", path_relative_to_include())
  cloud      = local.path_parts[1]

  aws_provider = <<EOF
provider "aws" {
  region = "us-west-1"
}
EOF

  azure_provider = <<EOF
provider "azurerm" {
  features {}
}
EOF
}

remote_state {
  backend = local.cloud == "aws" ? "s3" : "azurerm"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = local.cloud == "aws" ? {
    bucket       = "isre-devops-terraform-state-139337686739"
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = "us-west-1"
    encrypt      = true
    use_lockfile = true
  } : {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate05072026dev"
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = local.cloud == "aws" ? local.aws_provider : local.azure_provider
}
