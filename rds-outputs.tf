output "db_endpoint" {
  value = aws_db_instance.primary.address
}

output "db_replica_endpoint" {
  value = aws_db_instance.read_replica.address
}