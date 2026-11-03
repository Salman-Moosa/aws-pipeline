# Dev state location in AWS S3 (bucket must already exist)
bucket       = "wanderfy-test-access01"
key          = "wanderfy/aws/dev/terraform.tfstate"
region       = "ca-central-1"
encrypt      = true
use_lockfile = true