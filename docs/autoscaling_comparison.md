# EKS Autoscaling: Karpenter vs. Cluster Autoscaler (CAS)

This document compares the two primary autoscaling solutions for Amazon EKS to provide architectural context for the selection of Karpenter.

| Feature | Cluster Autoscaler (CAS) | Karpenter |
| :--- | :--- | :--- |
| **Mechanism** | Scaled AWS Auto Scaling Groups (ASGs). | Provisions EC2 instances directly (Bypasses ASGs). |
| **Performance** | Slower. Must wait for ASG to trigger and EC2 to initialize. | Faster. "Just-in-time" provisioning in milliseconds. |
| **Instance Selection** | Limited to types defined in the ASG. | Dynamic. Picks the best instance for the pod's requirements. |
| **Bin Packing** | Basic. Relies on scheduler defaults. | Aggressive. Actively consolidates pods to reduce costs. |
| **Maintenance** | Manual ASG updates. | Automated. Can replace nodes for security/updates automatically. |
| **Configuration** | Managed via ASG tags and annotations. | Managed via Kubernetes CRDs (`NodePool`, `EC2NodeClass`). |

## Why Karpenter for this Project?

1. **Efficiency**: Karpenter avoids the "pending pod" delay common with CAS by starting the instance provisioning process as soon as a pod is marked unschedulable.
2. **Cost Optimization**: In a dev environment, Karpenter can dynamically use SPOT instances of various sizes, ensuring you don't over-provision.
3. **Simplified Infrastructure**: By removing the need for many different ASGs for different instance types/AZs, it reduces Terraform complexity.
4. **Modern Standard**: AWS is heavily investing in Karpenter as the successor to CAS for most EKS use cases.
