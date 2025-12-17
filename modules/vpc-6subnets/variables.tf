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
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "public_subnet_cidrs phải có đúng 2 CIDR."
  }
}

variable "private_subnet_cidrs" {
  type = list(string)
  validation {
    condition     = length(var.private_subnet_cidrs) == 4
    error_message = "private_subnet_cidrs phải có đúng 4 CIDR."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags merged into resource tags"
  default     = {}
}
