terraform {
  source = "../../../../modules/aws/s3-bucket"
}

# We explicitly don't include the root.hcl here because this module 
# creates the bucket that the root.hcl expects to exist.
# This avoids a chicken-and-egg problem.

inputs = {
  bucket_name = "terraform-state-aws-dev-05072026"
}
