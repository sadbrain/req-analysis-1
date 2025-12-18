output "maintenance_parameter_name" {
  value = aws_ssm_parameter.maintenance_mode.name
}

output "lambda_function_name" {
  value = aws_lambda_function.maintenance_toggle.function_name
}
