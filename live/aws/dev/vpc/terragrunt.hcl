terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.1.2"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  name = "vpc-dev"
  cidr = "10.100.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
  public_subnets  = ["10.100.101.0/24", "10.100.102.0/24", "10.100.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery"          = "eks-dev-cluster"
  }

  tags = {
    Environment = "dev"
    Project     = "platform-engineering"
  }
}
