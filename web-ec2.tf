# =============================================
#   Web Tier - EC2 Instances + User Data (Nginx)
# =============================================

resource "aws_instance" "web_ec2" {
  count = 2   # Creating 2 instances for high availability

  ami                    = "ami-0d682f26195e9ec0f"   # Amazon Linux 2023 (ap-south-1)
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.public_subnets[count.index]
  vpc_security_group_ids = [aws_security_group.web_ec2.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install nginx -y
              systemctl enable nginx
              systemctl start nginx

              # Simple welcome page to test
              echo '<!DOCTYPE html>
              <html>
              <head><title>Three Tier App - Web Tier</title></head>
              <body>
                <h1 style="color:green;">✅ Web Tier is Running Successfully!</h1>
                <h2>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</h2>
                <p>Public ALB is working</p>
              </body>
              </html>' > /usr/share/nginx/html/index.html

              systemctl restart nginx
              EOF

  tags = {
    Name        = "${var.project_name}-web-ec2-${count.index + 1}"
    Tier        = "Web"
    Environment = "dev"
  }
}

# Attach Web EC2 instances to the Target Group
resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_ec2[count.index].id
  port             = 80
}

# Output Web EC2 Public IPs
output "web_ec2_public_ips" {
  value       = aws_instance.web_ec2[*].public_ip
  description = "Public IPs of Web EC2 Instances"
}