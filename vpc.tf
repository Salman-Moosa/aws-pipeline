#######
# VPC #
#######
# Creates the VPC with public, private (app) and database subnet tiers.
module "vpc" {
  source = "git::https://github.com/Salman-Moosa/aws-module.git//vpc?ref=main"

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr
  azs  = local.azs

  # Public subnets: internet-facing load balancers and the NAT gateway
  public_subnets = {
    list = local.public_subnets
    tags = { "kubernetes.io/role/elb" = "1" }
    inbound_acl_rules = [
      # Deny RDP: it falls within the ephemeral port range allowed by rule 900
      { rule_number = 1, rule_action = "deny", protocol = "tcp", from_port = 3389, to_port = 3389, cidr_block = "0.0.0.0/0" },
      { rule_number = 10, rule_action = "allow", protocol = "-1", from_port = 0, to_port = 0, cidr_block = var.vpc_cidr },
      { rule_number = 40, rule_action = "allow", protocol = "tcp", from_port = 443, to_port = 443, cidr_block = "0.0.0.0/0" },
      # Return traffic for the NAT gateway, which lives in the public subnets
      { rule_number = 900, rule_action = "allow", protocol = "tcp", from_port = 1024, to_port = 65535, cidr_block = "0.0.0.0/0" },
    ]
  }

  # Private subnets: application workloads and internal load balancers
  private_subnets = {
    list = local.private_subnets
    tags = { "kubernetes.io/role/internal-elb" = "1" }
    inbound_acl_rules = [
      { rule_number = 10, rule_action = "allow", protocol = "-1", from_port = 0, to_port = 0, cidr_block = var.vpc_cidr },
      # Return traffic from the internet (via NAT) and the S3 gateway endpoint
      { rule_number = 900, rule_action = "allow", protocol = "tcp", from_port = 1024, to_port = 65535, cidr_block = "0.0.0.0/0" },
    ]
  }

  # Database subnets: Aurora and Valkey only, no internet route
  database_subnets = {
    list = local.database_subnets
    inbound_acl_rules = concat(
      # PostgreSQL from the private (app) subnets only
      [for i, cidr in local.private_subnets : { rule_number = 10 + i, rule_action = "allow", protocol = "tcp", from_port = local.aurora_port, to_port = local.aurora_port, cidr_block = cidr }],
      # Replication between the database subnets
      [for i, cidr in local.database_subnets : { rule_number = 20 + i, rule_action = "allow", protocol = "-1", from_port = 0, to_port = 0, cidr_block = cidr }],
      # Valkey from the private (app) subnets only
      [for i, cidr in local.private_subnets : { rule_number = 30 + i, rule_action = "allow", protocol = "tcp", from_port = local.valkey_port, to_port = local.valkey_port, cidr_block = cidr }],
    )
    outbound_acl_rules = concat(
      [for i, cidr in local.private_subnets : { rule_number = 10 + i, rule_action = "allow", protocol = "tcp", from_port = 1024, to_port = 65535, cidr_block = cidr }],
      [for i, cidr in local.database_subnets : { rule_number = 20 + i, rule_action = "allow", protocol = "-1", from_port = 0, to_port = 0, cidr_block = cidr }],
    )
  }

  # NAT gateway
  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = !var.single_nat_gateway

  # Flow logs
  enable_flow_log = var.enable_flow_log

  # VPC endpoints
  vpc_endpoints = local.vpc_endpoints
}