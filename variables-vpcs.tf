variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "azs" {
  type = list(object({
    name                 = string
    public_subnet_cidrs  = list(string)
    private_subnet_cidrs = list(string)
  }))
  description = "List of AZs with their subnet CIDRs"
}