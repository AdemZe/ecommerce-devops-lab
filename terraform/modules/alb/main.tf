# MODULE: APPLICATION LOAD BALANCER
# Creates: ALB, Target Group, HTTP Listener


locals {
  name_prefix = "${var.project_name}-${var.environment}"
}



# ── APPLICATION LOAD BALANCER ────────────────────────────────
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false   # Set true in real production

  tags = { Name = "${local.name_prefix}-alb" }
}

# ── TARGET GROUP ─────────────────────────────────────────────
resource "aws_lb_target_group" "web" {
  name     = "${local.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }

  tags = { Name = "${local.name_prefix}-tg" }
}


# ── HTTP LISTENER ────────────────────────────────────────────
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
