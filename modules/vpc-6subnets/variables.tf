variable "name" {
  type        = string
  description = "Name prefix for VPC resources"
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name for SSH access"
  default     = ""
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "azs" {
  type = list(object({
    name                  = string
    public_subnet_cidrs   = list(string)
    private_subnet_cidrs  = list(string)
  }))
  description = "List of AZs with their subnet CIDRs"
}

variable "tags" {
  type        = map(string)
  description = "Tags merged into resource tags"
  default     = {}
}
