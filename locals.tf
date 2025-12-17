locals {
  # Default tags applied to all resources
  default_tags = merge(
    {
      Project = var.project
      Env     = var.env
      Managed = "terraform"
    },
    var.tags
  )

  # Public subnets - directly from VPC module
  public_subnets = module.vpc.public_subnet_ids

  # App subnets (slot 1) - for ECS, NAT routing
  private_app_subnets = module.vpc.private_app_subnet_ids

  # DB subnets (slot 2+) - for RDS
  private_db_subnets = module.vpc.private_db_subnet_ids

  # Number of AZs - computed dynamically
  az_count = length(var.azs)

  # Extract AZ names for modules that need list(string)
  az_names = [for az in var.azs : az.name]
}
