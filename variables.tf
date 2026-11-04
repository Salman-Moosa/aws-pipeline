variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR range for the environment VPC."
  type        = string
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for the environment."
  type        = bool
}

variable "enable_flow_log" {
  description = "Enable VPC flow logs."
  type        = bool
}
variable "vpc_name" {
  description = "Name of the environment VPC."
  type        = string
}