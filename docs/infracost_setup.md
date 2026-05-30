# Proactive Cost Estimation with Infracost

Infracost is a tool that allows you to see the cost impact of your infrastructure changes **before** you apply them. This is a critical component of our "Shift-Left" FinOps strategy.

## How it fits into our Workflow

| Tool | Phase | Purpose |
| :--- | :--- | :--- |
| **Infracost** | **Planning** | Proactive estimation of costs for new changes. |
| **AWS CUR** | **Monitoring** | Accurate retroactive billing and chargeback analysis. |

## Usage Guide for Terragrunt

Because this project uses Terragrunt, we can run Infracost for a specific module or the entire environment.

### 1. Installation (Local Dev)
```bash
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
infracost auth login
```

### 2. Running Breakdown for a Specific Module
Navigate to a resource directory (e.g., `live/aws/dev/vpc`) and run:

```bash
# 1. Generate the plan
terragrunt plan -out tfplan.binary

# 2. Convert to JSON
terragrunt show -json tfplan.binary > tfplan.json

# 3. Run Infracost
infracost breakdown --path tfplan.json
```

### 3. Comparison Mode (Diff)
To see exactly how much your costs will change compared to the current state:

```bash
infracost diff --path tfplan.json
```

## Why use Infracost here?
- **EKS Costing**: Estimating the cost of different `instance_types` for the node group.
- **NAT Gateway**: Visualizing the impact of switching from `single_nat_gateway` to `one_nat_gateway_per_az`.
- **Spot Savings**: It correctly identifies and calculates the savings when using `SPOT` capacity for Karpenter nodes.

## Recommended CI/CD Integration
In a production environment, Infracost should be integrated into your PR pipeline (GitHub Actions/GitLab CI). It will comment on the PR with a cost breakdown, allowing engineers to catch expensive mistakes before they merge.
