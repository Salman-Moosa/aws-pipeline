############
# Provider #
############
# Credentials come from the standard AWS environment (AWS_PROFILE, env vars or OIDC).
provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}