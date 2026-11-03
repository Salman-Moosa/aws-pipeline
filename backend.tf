###########
# Backend #
###########
# Selects the AWS S3 remote backend. Environment-specific values are
# supplied with -backend-config=backend/<environment>.hcl.
terraform {
  backend "s3" {}
}