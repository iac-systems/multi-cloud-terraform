terraform {
  source = "../../../../modules/aws/s3-bucket"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "us-west-1"
}
EOF
}

# We explicitly don't include the root.hcl here because this module 
# creates the bucket that the root.hcl expects to exist.
# This avoids a chicken-and-egg problem.

inputs = {
  bucket_name = "isre-devops-terraform-state-139337686739"
}
