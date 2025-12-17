output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "nat_sg_id" {
  value = aws_security_group.nat.id
}

output "ecs_sg_id" {
  value = aws_security_group.ecs.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}
