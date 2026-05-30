terraform {
  source = "../../../../modules/aws/finops"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  bucket_name = "aws-finops-cur-05072026"
  report_name = "eks-platform-cost-report"
}
