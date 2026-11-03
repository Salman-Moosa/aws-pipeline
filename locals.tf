#################
# Shared values #
#################
# Values shared by every environment. Per-environment values live in env/<environment>.tfvars.
locals {
  # General
  project     = "wanderfy"
  region      = "ca-central-1"
  azs         = ["ca-central-1a", "ca-central-1b", "ca-central-1d"]
  name_prefix = "${local.project}-${var.environment}"

  # Tags applied to every resource via the provider's default_tags
  tags = {
    Project     = local.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  # VPC: one subnet per AZ per tier, carved from the environment's /16.
  # Public and database are /24s in the first /20 (x.x.0.0-x.x.15.255); private gets a /20 per AZ for EKS pod IPs.
  public_subnets   = [for i, _ in local.azs : cidrsubnet(var.vpc_cidr, 8, i + 1)]  # /24: x.x.1-3.0
  database_subnets = [for i, _ in local.azs : cidrsubnet(var.vpc_cidr, 8, i + 11)] # /24: x.x.11-13.0
  private_subnets  = [for i, _ in local.azs : cidrsubnet(var.vpc_cidr, 4, i + 1)]  # /20: x.x.16.0, x.x.32.0, x.x.48.0

  # App subnets allowed to reach Aurora and Valkey (EKS nodes and Fargate pods), keyed by a static name
  app_cidr_blocks = { for i, az in local.azs : "private-${az}" => local.private_subnets[i] }

  # VPC endpoints: the gateway endpoint is free and keeps S3 traffic off the NAT gateway
  vpc_endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      tags         = { Name = "${local.name_prefix}-s3-vpc-endpoint" }
    }
  }

  # Service ports used by subnet ACL rules before those service modules are added.
  aurora_port = 5432
  valkey_port = 6379

  # # Aurora PostgreSQL
  # aurora_engine_version = "18.6"
  # aurora_database_name  = local.project
  # aurora_cluster_parameters = [
  #   { name = "rds.force_ssl", value = "1" },
  #   { name = "log_min_duration_statement", value = "1000" },
  # ]
  # aurora_maintenance_window = "Sun:04:00-Sun:05:00"
  # aurora_backup_window      = "03:00-04:00"

  # # EKS
  # eks_kubernetes_version = "1.36"

  # # ElastiCache (Valkey)
  # valkey_engine_version     = "9.1"
  # valkey_maintenance_window = "sun:05:00-sun:06:00"
  # valkey_snapshot_window    = "03:00-04:00"
}