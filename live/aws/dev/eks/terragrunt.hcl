terraform {
  source = "../../../../modules/aws/eks"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  name               = "eks-dev-cluster"
  kubernetes_version = "1.34"

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets

  # Cluster endpoint access
  cluster_endpoint_public_access = true

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    minimal = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"

      labels = {
        "karpenter.sh/controller" = "true"
      }
    }
  }

  cluster_addons = {
    vpc-cni = {
      before_compute = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    eks-pod-identity-agent = {}
  }

  # Enable IAM Roles for Service Accounts (IRSA)
  enable_irsa = true

  node_security_group_tags = {
    "karpenter.sh/discovery" = "eks-dev-cluster"
  }

  # Ensure the cluster creator has admin permissions
  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "dev"
    Project     = "platform-engineering"
  }
}
