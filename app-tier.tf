# =============================================
#   App Tier - Internal ALB + Node.js EC2
# =============================================

# 1. Internal Application Load Balancer
resource "aws_lb" "internal_alb" {
  name               = "${var.project_name}-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_internal.id]
  subnets            = module.vpc.private_subnets

  tags = {
    Name        = "${var.project_name}-internal-alb"
    Tier        = "App"
    Environment = "dev"
  }
}

# 2. Target Group for Node.js (port 8080)
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

# 3. Listener for Internal ALB
resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# 4. App Tier EC2 Instances (Node.js)
resource "aws_instance" "app_ec2" {
  count = 2

  ami                         = "ami-0d682f26195e9ec0f"
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.private_subnets[count.index]
  vpc_security_group_ids      = [aws_security_group.app_ec2.id]
  associate_public_ip_address = false

  # NOTE: $${} escapes Terraform interpolation so the $ reaches the shell/JS at runtime
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y nodejs npm

              mkdir -p /home/ec2-user/app
              cat << 'NODEAPP' > /home/ec2-user/app/server.js
              const express = require('express');
              const app = express();
              const port = 8080;

              app.get('/', (req, res) => {
                res.json({
                  message: "Hello from App Tier - Node.js Express",
                  instance: process.env.INSTANCE_ID || "Unknown",
                  tier: "App Tier",
                  timestamp: new Date().toISOString()
                });
              });

              app.get('/health', (req, res) => {
                res.status(200).send('OK');
              });

              app.listen(port, () => {
                console.log(`App Tier running on port $${port}`);
              });
              NODEAPP

              # Get instance ID from EC2 metadata
              INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

              cd /home/ec2-user/app
              npm init -y
              npm install express

              # Create systemd service
              cat << 'SERVICE' > /etc/systemd/system/nodeapp.service
              [Unit]
              Description=Node.js App Tier Service
              After=network.target

              [Service]
              User=ec2-user
              WorkingDirectory=/home/ec2-user/app
              ExecStart=/usr/bin/node server.js
              Restart=always
              Environment=INSTANCE_ID=$${INSTANCE_ID}

              [Install]
              WantedBy=multi-user.target
              SERVICE

              systemctl daemon-reload
              systemctl enable nodeapp
              systemctl start nodeapp

              echo "Node.js App Tier deployment completed successfully"
              EOF

  tags = {
    Name        = "${var.project_name}-app-ec2-${count.index + 1}"
    Tier        = "App"
    Environment = "dev"
  }
}

# 5. Attach App EC2 to Target Group
resource "aws_lb_target_group_attachment" "app_tg_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_ec2[count.index].id
  port             = 8080
}

# Outputs
output "internal_alb_dns" {
  value       = aws_lb.internal_alb.dns_name
  description = "Internal ALB DNS Name"
}

output "app_ec2_private_ips" {
  value       = aws_instance.app_ec2[*].private_ip
  description = "Private IPs of App Tier Instances"
}