vpc_cidr = "10.10.0.0/16"
azs      = ["ap-northeast-1a", "ap-northeast-1c"]

public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24", "10.10.14.0/24"]

tags = {
  Environment = "dev"
  Owner       = "mixcre"
}