# Deployment Guide

This document provides an overview of the project structure and instructions for deploying infrastructure using Terraform and Terragrunt.

## Project Structure

The repository follows a Terragrunt-based multi-environment structure:

```text
.
├── docs
│   └── deploy_steps.md
├── global
│   └── azure
│       └── state-storage
├── LICENSE
├── live
│   └── azure
│       ├── dev
│       │   ├── aks
│       │   │   └── terragrunt.hcl
│       │   ├── keyvault
│       │   │   └── terragrunt.hcl
│       │   ├── networking
│       │   │   └── terragrunt.hcl
│       │   └── resource-group
│       │       └── terragrunt.hcl
│       ├── prod
│       │   └── networking
│       │       └── terragrunt.hcl
│       └── stg
│           └── networking
│               └── terragrunt.hcl
├── modules
│   └── azure
│       ├── aks
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   ├── variables.tf
│       │   └── versions.tf
│       ├── keyvault
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   ├── variables.tf
│       │   └── versions.tf
│       ├── nat-gateway
│       ├── resource-group
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   ├── variables.tf
│       │   └── versions.tf
│       ├── storage-account
│       ├── subnet
│       └── vnet
│           ├── main.tf
│           ├── outputs.tf
│           ├── variables.tf
│           └── versions.tf
├── provider.tf
├── README.md
├── root.hcl
├── scripts
│   └── create-terraform-structure.sh
├── terragrunt.hcl
└── versions.tf

26 directories, 30 files
```

### Key Components

- **`root.hcl`**: Defines the remote state backend (Azure Blob Storage) and common provider settings. It uses `path_relative_to_include()` to dynamically set the state key.
- **`modules/`**: Contains pure Terraform code for various resources. These are intended to be generic and reusable.
- **`live/`**: Contains `terragrunt.hcl` files for each resource in each environment. These files reference the modules and provide environment-specific inputs.

## Local Deployment Commands

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed.
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) installed.
- Azure CLI installed.

### Authentication

There are two primary ways to authenticate with Azure for local deployment:

#### Option 1: Azure CLI (Recommended for local dev)
Log in via the interactive CLI:
```bash
az login
```

#### Option 2: Service Principal (Recommended for CI/CD or non-interactive)
Export the following environment variables:
```bash
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

### Steps to Deploy

#### 1. Navigate to the desired environment/resource
```bash
cd live/azure/dev/networking
```

#### 2. Initialize and Plan
To see what changes will be made:
```bash
terragrunt plan
```

#### 3. Apply Changes
To deploy the infrastructure:
```bash
terragrunt apply
```

#### 4. Deploying an Entire Environment
To deploy all resources within an environment (respecting dependencies):
```bash
cd live/azure/dev
terragrunt run-all plan
terragrunt run-all apply
```

### Common Commands

- `terragrunt init`: Initialize the working directory.
- `terragrunt output`: View the outputs of a deployed module.
- `terragrunt destroy`: Tear down the infrastructure for a specific module.
- `terragrunt run-all destroy`: Tear down an entire environment.
