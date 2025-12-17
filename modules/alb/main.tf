# ============================================================================
# ALB MODULE
# ============================================================================

resource "aws_lb" "app" {
  name               = "${var.project}-${var.env}-alb"
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnets

  enable_deletion_protection = false
#   enable_http2              = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "fe" {
  name        = "${var.project}-${var.env}-fe"
  port        = var.fe_container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.alb_healthcheck_path_fe
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  deregistration_delay = 30

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "fe_green" {
  name        = "${var.project}-${var.env}-fe-green"
  port        = var.fe_container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.alb_healthcheck_path_fe
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  deregistration_delay = 30

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "be" {
  name        = "${var.project}-${var.env}-be"
  port        = var.be_container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.alb_healthcheck_path_be
    matcher             = "200-299,404"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  deregistration_delay = 30

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http_80" {
  load_balancer_arn = aws_lb.app.arn
  port              = var.alb_listener_port_fe
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fe.arn
  }
}

resource "aws_lb_listener_rule" "fe_green" {
  listener_arn = aws_lb_listener.http_80.arn
  priority     = 1

  condition {
    path_pattern {
      values = ["/green*", "/green/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fe_green.arn
  }
}

resource "aws_lb_listener" "http_8080" {
  load_balancer_arn = aws_lb.app.arn
  port              = var.alb_listener_port_be
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.be.arn
  }
}
