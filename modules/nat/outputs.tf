output "nat_instance_ids" {
  value = aws_instance.nat[*].id
}

output "nat_public_ips" {
  value = aws_instance.nat[*].public_ip
}
