provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = local.default_tags
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}
