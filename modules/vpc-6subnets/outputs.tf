output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [for k in sort(keys(aws_subnet.public)) : aws_subnet.public[k].id]
}

output "private_subnet_ids" {
  value = [for k in sort(keys(aws_subnet.private)) : aws_subnet.private[k].id]
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "private_app_route_table_ids" {
  value = [for rt in aws_route_table.private_app : rt.id]
}

output "private_db_route_table_id" {
  value = aws_route_table.private_db.id
}
