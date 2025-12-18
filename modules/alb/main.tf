# ============================================================================
# ALB MODULE
# ============================================================================

resource "aws_lb" "app" {
  name               = "${var.project}-${var.env}-internal-alb"
  load_balancer_type = "application"
  internal           = true # Internal ALB - only accessible via CloudFront
  security_groups    = [var.alb_security_group_id]
  subnets            = var.private_app_subnets

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

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 3600 # 1 hour
    enabled         = true
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

  # Enable sticky sessions for SignalR/WebSocket
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 3600 # 1 hour
    enabled         = true
  }

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
    host_header {
      values = ["green.mixcredevops.online"]
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
