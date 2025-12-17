output "fe_service_name" {
  value = aws_ecs_service.fe.name
}

output "fe_service_id" {
  value = aws_ecs_service.fe.id
}

output "fe_task_definition_arn" {
  value = aws_ecs_task_definition.fe.arn
}

output "be_service_name" {
  value = aws_ecs_service.be.name
}

output "be_service_id" {
  value = aws_ecs_service.be.id
}

output "be_task_definition_arn" {
  value = aws_ecs_task_definition.be.arn
}
