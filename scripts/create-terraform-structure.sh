#!/bin/bash

set -e

PROJECT_NAME="multi-cloud-terraform"

echo "Creating Terraform + Terragrunt Azure VNet Module Structure..."

mkdir -p ${PROJECT_NAME}

cd ${PROJECT_NAME}

############################################
# ROOT FILES
############################################

cat <<EOF > terragrunt.hcl
remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateprod001"
    container_name       = "tfstate"
    key                  = "\${path_relative_to_include()}/terraform.tfstate"
  }
}
EOF

cat <<EOF > provider.tf
provider "azurerm" {
  features {}
}
EOF

cat <<EOF > versions.tf
terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
EOF

cat <<EOF > .gitignore
.terraform/
*.tfstate
*.tfstate.backup
.terragrunt-cache/
crash.log
EOF

touch README.md

############################################
# MODULE STRUCTURE
############################################

mkdir -p modules/azure/vnet

############################################
# variables.tf
############################################

cat <<EOF > modules/azure/vnet/variables.tf
variable "resource_group_name" {
  description = "Azure Resource Group Name"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  type        = string
}

variable "vnet_name" {
  description = "Virtual Network Name"
  type        = string
}

variable "vnet_cidr" {
  description = "VNet CIDR Range"
  type        = string
}

variable "tags" {
  description = "Common Tags"
  type        = map(string)
  default     = {}
}
EOF

############################################
# main.tf
############################################

cat <<EOF > modules/azure/vnet/main.tf
locals {

  subnet_config = {
    aks_nodes = {
      newbits = 4
      netnum  = 0
    }

    aks_pods = {
      newbits = 2
      netnum  = 1
    }

    internal_services = {
      newbits = 8
      netnum  = 80
    }

    private_endpoints = {
      newbits = 8
      netnum  = 81
    }

    ingress = {
      newbits = 8
      netnum  = 82
    }

    bastion = {
      newbits = 10
      netnum  = 332
    }

    monitoring = {
      newbits = 8
      netnum  = 84
    }

    database = {
      newbits = 8
      netnum  = 85
    }
  }

  calculated_subnets = {
    for name, cfg in local.subnet_config :
    name => cidrsubnet(
      var.vnet_cidr,
      cfg.newbits,
      cfg.netnum
    )
  }
}

resource "azurerm_virtual_network" "this" {

  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = [
    var.vnet_cidr
  ]

  tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "vnet"
    },
    var.tags
  )
}

resource "azurerm_subnet" "subnets" {

  for_each = local.calculated_subnets

  name                 = "\${var.environment}-\${each.key}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [
    each.value
  ]
}
EOF

############################################
# outputs.tf
############################################

cat <<EOF > modules/azure/vnet/outputs.tf
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
EOF

############################################
# LIVE ENVIRONMENTS
############################################

for env in dev stg prod
do

mkdir -p live/azure/${env}/networking

if [ "$env" == "dev" ]; then
  CIDR="10.10.0.0/16"
fi

if [ "$env" == "stg" ]; then
  CIDR="10.20.0.0/16"
fi

if [ "$env" == "prod" ]; then
  CIDR="10.30.0.0/16"
fi

cat <<EOF > live/azure/${env}/networking/terragrunt.hcl
terraform {
  source = "../../../../modules/azure/vnet"
}

include {
  path = find_in_parent_folders()
}

inputs = {

  resource_group_name = "rg-${env}-platform"

  location = "Central India"

  environment = "${env}"

  vnet_name = "vnet-${env}-platform"

  vnet_cidr = "${CIDR}"

  tags = {
    Environment = "${env}"
    Project     = "platform-engineering"
    Owner       = "devops-team"
  }
}
EOF

done

############################################
# DONE
############################################

echo ""
echo "======================================="
echo "Terraform + Terragrunt structure ready!"
echo "======================================="
echo ""

#tree .
