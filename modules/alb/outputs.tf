output "alb_id" {
  value = aws_lb.app.id
}

output "alb_arn" {
  value = aws_lb.app.arn
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "http_80_listener_arn" {
  value = aws_lb_listener.http_80.arn
}

output "fe_target_group_arn" {
  value = aws_lb_target_group.fe.arn
}

output "fe_green_target_group_arn" {
  value = aws_lb_target_group.fe_green.arn
}

output "be_target_group_arn" {
  value = aws_lb_target_group.be.arn
}
