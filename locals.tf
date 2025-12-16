locals {
  default_tags = merge(
    {
      Project = var.project
      Env     = var.env
      Managed = "terraform"
    },
    var.tags
  )
}
