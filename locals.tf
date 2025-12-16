data "aws_subnet" "private" {
  for_each = toset(module.vpc.private_subnet_ids)
  id       = each.value
}

locals {
  default_tags = merge(
    {
      Project = var.project
      Env     = var.env
      Managed = "terraform"
    },
    var.tags
  )

  public_subnets = module.vpc.public_subnet_ids

  private_by_az = {
    for az in var.azs :
    az => sort([
      for s in values(data.aws_subnet.private) : s.id
      if s.availability_zone == az
    ])
  }

  private_app_subnets = [for az in var.azs : local.private_by_az[az][0]]

  private_db_subnets = [
    for az in var.azs : local.private_by_az[az][length(local.private_by_az[az]) - 1]
  ]
}
