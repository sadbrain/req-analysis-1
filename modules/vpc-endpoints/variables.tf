# ============================================================================
# VPC ENDPOINTS VARIABLES
# ============================================================================

variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for interface endpoints"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "List of private route table IDs for gateway endpoints"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ECS security group ID to allow access to endpoints"
  type        = string
}

variable "enable_dynamodb_endpoint" {
  description = "Enable DynamoDB gateway endpoint"
  type        = bool
  default     = false
}
