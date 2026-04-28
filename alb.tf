# =============================================
#   Public Application Load Balancer (Web Tier)
# =============================================

# 1. Public ALB
resource "aws_lb" "public_alb" {
  name               = "${var.project_name}-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_public.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-public-alb"
    Tier        = "Web"
    Environment = "dev"
  }
}

# 2. Target Group for Web EC2 (Nginx)
resource "aws_lb_target_group" "web_tg" {
  name     = "${var.project_name}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200-399"
  }

  tags = {
    Name        = "${var.project_name}-web-tg"
    Tier        = "Web"
    Environment = "dev"
  }
}

# 3. Listener - HTTP on Port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Output for ALB DNS
output "public_alb_dns" {
  value       = aws_lb.public_alb.dns_name
  description = "Public ALB DNS Name (This will be your application URL)"
}