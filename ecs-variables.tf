variable "ecs_instance_type" {
  type    = string
  default = "t3a.micro"
}

variable "ecs_desired_capacity" {
  type    = number
  default = 2
}

variable "ecs_min_size" {
  type    = number
  default = 2
}

variable "ecs_max_size" {
  type    = number
  default = 4
}

variable "fe_image" { type = string }
variable "fe_green_image" { type = string }
variable "be_image" { type = string }

variable "fe_desired_count" {
  type    = number
  default = 1
}
variable "fe_green_desired_count" {
  type    = number
  default = 1
}
variable "be_desired_count" {
  type    = number
  default = 1
}

variable "be_env" {
  type    = map(string)
  default = {}
}