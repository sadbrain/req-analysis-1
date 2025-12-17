variable "ecs_instance_type" {
  type        = string
  description = "Instance type for ECS instances"
  default     = "t3.micro"
}

variable "ecs_desired_capacity" {
  type        = number
  description = "Desired number of ECS instances"
  default     = 2
}

variable "ecs_min_size" {
  type        = number
  description = "Minimum number of ECS instances"
  default     = 2
}

variable "ecs_max_size" {
  type        = number
  description = "Maximum number of ECS instances"
  default     = 4
}

variable "fe_container_port" {
  type        = number
  description = "Frontend container port"
  default     = 80
}

variable "be_container_port" {
  type        = number
  description = "Backend container port"
  default     = 8080
}

variable "fe_desired_count" {
  type        = number
  description = "Desired count for frontend service"
  default     = 2
}

variable "be_desired_count" {
  type        = number
  description = "Desired count for backend service"
  default     = 2
}

variable "fe_image" {
  type        = string
  description = "Docker image for frontend"
}

variable "be_image" {
  type        = string
  description = "Docker image for backend"
}

variable "be_env" {
  type        = map(string)
  description = "Environment variables for backend container"
  default     = {}
}