output "asg_name" {
  value = aws_autoscaling_group.ecs.name
}

output "asg_arn" {
  value = aws_autoscaling_group.ecs.arn
}

# output "capacity_provider_name" {
#   value = aws_ecs_capacity_provider.this.name
# }

output "launch_template_id" {
  value = aws_launch_template.ecs.id
}
