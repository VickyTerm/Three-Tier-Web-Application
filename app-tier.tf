# =============================================
#   App Tier - Internal ALB + Node.js Express
# =============================================

# 1. Internal Application Load Balancer
resource "aws_lb" "internal_alb" {
  name               = "${var.project_name}-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_internal.id]
  subnets            = module.vpc.private_subnets   # Use all private subnets (should be your App tier subnets)

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-internal-alb"
    Tier        = "App"
    Environment = "dev"
  }
}

# 2. Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project_name}-app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/health"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200"
  }

  tags = {
    Name        = "${var.project_name}-app-tg"
    Tier        = "App"
    Environment = "dev"
  }
}

# 3. Listener
resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# 4. Launch Template
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project_name}-app-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  key_name      = "three-tier-app-web-key"

  vpc_security_group_ids = [aws_security_group.app_ec2.id]

  user_data = base64encode(file("${path.module}/scripts/app_user_data.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-app"
      Tier        = "App"
      Environment = "dev"
    }
  }
}

# 5. Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                = "${var.project_name}-app-asg"
  vpc_zone_identifier = module.vpc.private_subnets

  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns         = [aws_lb_target_group.app_tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 180

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app-asg"
    propagate_at_launch = true
  }
}

# Outputs
output "internal_alb_dns" {
  value       = aws_lb.internal_alb.dns_name
  description = "Internal ALB DNS Name - Use this in Web tier Nginx proxy_pass"
}