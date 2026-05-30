terraform {
  source = "../../../../modules/aws/karpenter-resources"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "eks" {
  config_path = "../eks"
}

dependency "karpenter_iam" {
  config_path = "../karpenter"
}

inputs = {
  cluster_name                       = dependency.eks.outputs.cluster_name
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  
  karpenter_node_role_name           = dependency.karpenter_iam.outputs.node_iam_role_name
  interruption_queue_name            = dependency.karpenter_iam.outputs.queue_name
}
