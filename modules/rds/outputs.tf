output "primary_endpoint" {
  value = aws_db_instance.primary.endpoint
}

output "primary_address" {
  value = aws_db_instance.primary.address
}

output "primary_identifier" {
  value = aws_db_instance.primary.identifier
}

output "read_replica_endpoint" {
  value = aws_db_instance.read_replica.endpoint
}

output "read_replica_address" {
  value = aws_db_instance.read_replica.address
}

output "db_name" {
  value = aws_db_instance.primary.db_name
}
