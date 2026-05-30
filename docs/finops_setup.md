# AWS FinOps: Cost and Usage Reporting (CUR)

This document provides details on the FinOps stack implemented to track and analyze AWS costs, specifically for the EKS platform.

## Implementation Details

The stack is located in `live/aws/global/finops` and uses the module at `modules/aws/finops`.

### Components
1. **S3 Bucket (`aws-finops-cur-05072026`)**:
   - Purpose: Secure storage for raw and Parquet-formatted billing data.
   - Security: Enabled Server-Side Encryption (AES256) and Versioning.
   - Permissions: Configured with a specialized bucket policy allowing the AWS Billing service to write reports.

2. **CUR Report Definition**:
   - **Name**: `eks-platform-cost-report`
   - **Region**: `us-east-1` (Mandatory for billing).
   - **Format**: `Parquet` (Optimized for Athena).
   - **Granularity**: `Hourly`.
   - **Artifacts**: Configured with `ATHENA` integration metadata.

## How to "Run" Reports

AWS Cost and Usage Reports are **automated**. You do not need to manually trigger them.
- **Initial Delivery**: It can take up to **24 hours** for the first report to appear after implementation.
- **Update Frequency**: AWS updates the reports at least once a day, usually every few hours.

## How to View and Analyze Reports

### 1. Raw Data in S3
You can browse the generated files directly in the AWS S3 Console:
- **Path**: `s3://aws-finops-cur-05072026/cur/eks-platform-cost-report/`

### 2. Analysis via Amazon Athena (Recommended)
Because we enabled the `ATHENA` artifact, AWS generates a CloudFormation template to set up the Athena table automatically.

**Steps to enable Athena:**
1. Navigate to the S3 bucket: `aws-finops-cur-05072026`.
2. Go to the prefix: `cur/eks-platform-cost-report/`.
3. Look for the `crawler-cfn.yml` file.
4. Download this file and run it in **AWS CloudFormation** in the `us-east-1` region.
5. This will create:
   - An AWS Glue Database.
   - An AWS Glue Crawler.
   - The necessary IAM roles.

Once the crawler runs, you can query your costs using standard SQL in the Athena console.

### 3. Example SQL Queries (Athena)
Once the table is created (usually named `eks_platform_cost_report`), you can run queries like:

**Total Cost by Service:**
```sql
SELECT 
  line_item_product_code, 
  sum(line_item_unblended_cost) AS total_cost
FROM "your_database"."your_table"
GROUP BY 1
ORDER BY 2 DESC;
```

**EKS Specific Costs (by Resource ID):**
```sql
SELECT 
  line_item_resource_id, 
  sum(line_item_unblended_cost) AS total_cost
FROM "your_database"."your_table"
WHERE line_item_product_code = 'AmazonEKS'
GROUP BY 1
ORDER BY 2 DESC;
```

## Best Practices
- **Lifecycle Rules**: As your lab grows, consider adding a lifecycle rule to move reports older than 90 days to S3 Glacier to save costs.
- **Tagging**: Ensure all EKS resources and Karpenter nodes are tagged consistently. These tags will appear as columns in your CUR report for granular chargeback analysis.
