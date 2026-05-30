# Karpenter Implementation Plan

This plan outlines the steps to migrate from a static Managed Node Group to a dynamic Karpenter-managed data plane.

## Phase 1: Infrastructure Preparation (Terraform/Terragrunt)

### 1.1 Add Discovery Tags
Update `live/aws/dev/vpc/terragrunt.hcl` to add the discovery tag to private subnets. This allows Karpenter to identify which subnets to use for new nodes.
- **Tag**: `karpenter.sh/discovery: eks-dev-cluster`

### 1.2 Update Security Group Tags
Update `live/aws/dev/eks/terragrunt.hcl` to tag the cluster security group.
- **Tag**: `karpenter.sh/discovery: eks-dev-cluster`

### 1.3 Provision Karpenter IAM Resources
Utilize the `modules/karpenter` sub-module within the EKS configuration to:
- Create the Karpenter Controller IAM Role (mapped via Pod Identity or IRSA).
- Create the Node IAM Role (which nodes launched by Karpenter will assume).
- Set up an SQS queue and EventBridge rules for Spot Interruption handling.

## Phase 2: Controller Deployment (Helm)

### 2.1 Install Karpenter via Helm
Deploy the Karpenter controller into the `kube-system` namespace.
- **Values**: Ensure the `serviceAccount` is annotated with the IAM Role ARN created in Phase 1.
- **Settings**: Set `clusterName` and `interruptionQueue`.

## Phase 3: Karpenter Configuration (Kubernetes Manifests)

### 3.1 Define EC2NodeClass
Create a `v1.EC2NodeClass` manifest to define provider-specific settings:
- Subnet selectors (using tags from 1.1).
- Security Group selectors (using tags from 1.2).
- AMI family (e.g., AL2023).

### 3.2 Define NodePool
Create a `v1.NodePool` manifest to define scaling logic:
- Constraints (Instance types, Architecture, Capacity type: Spot/On-Demand).
- Limits (Max CPU/Memory for the whole cluster).
- Disruption/Consolidation rules.

## Phase 4: Validation & Cleanup

### 4.1 Test Scaling
Deploy a heavy workload (e.g., a deployment with many replicas) and verify that Karpenter provisions new nodes automatically.

### 4.2 Scale Down Managed Node Group
Once Karpenter is stable, reduce the EKS Managed Node Group to a minimal size (e.g., 2 nodes) just to run the controller and system pods.
