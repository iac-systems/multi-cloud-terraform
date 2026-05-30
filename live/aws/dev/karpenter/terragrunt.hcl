terraform {
  source = "../../../../modules/aws/eks/modules/karpenter"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name

  # Enable Pod Identity for the Karpenter controller
  # Note: This requires the EKS Pod Identity Agent addon on the cluster
  enable_pod_identity             = true
  create_pod_identity_association = true

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_name = "eks-dev-cluster-karpenter-node"
  
  tags = {
    Environment = "dev"
    Project     = "platform-engineering"
  }
}
