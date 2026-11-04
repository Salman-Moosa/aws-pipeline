# General
environment = "dev"

# VPC
# env/dev.tfvars
vpc_name = "salman-dev-vpc"

vpc_cidr           = "10.10.0.0/16"
single_nat_gateway = true
enable_flow_log    = false

#only testing vpc rn
# # Aurora PostgreSQL
# aurora_instance_class      = "db.t4g.medium"
# aurora_instance_count      = 1
# aurora_deletion_protection = false
# aurora_skip_final_snapshot = true

# # EKS
# eks_admin_principal_arns = {
#   sso_admin = "arn:aws:iam::096925074508:role/aws-reserved/sso.amazonaws.com/ca-central-1/AWSReservedSSO_AdministratorAccess_30e03c2b94ae13b3"
# }
# eks_node_min_size       = 0
# eks_node_max_size       = 2
# eks_node_desired_size   = 1
# eks_node_capacity_type  = "SPOT"
# eks_node_instance_types = ["t3.medium", "t3a.medium"]

# # ElastiCache (Valkey)
# valkey_node_type                = "cache.t4g.micro"
# valkey_num_cache_clusters       = 1
# valkey_snapshot_retention_limit = 1

# S3
# s3_force_destroy = true