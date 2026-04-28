# =============================================
#   Web Tier - EC2 Instances with SSH Key
# =============================================

resource "aws_instance" "web_ec2" {
  count = 2

  ami                         = "ami-0d682f26195e9ec0f"   # Amazon Linux 2023 in ap-south-1
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnets[count.index]
  vpc_security_group_ids      = [aws_security_group.web_ec2.id]
  key_name                    = aws_key_pair.web_key.key_name     # SSH Key attached
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install nginx -y
              systemctl enable nginx
              systemctl start nginx

              # Create a simple test page
              cat << 'HTML' > /usr/share/nginx/html/index.html
              <!DOCTYPE html>
              <html>
              <head><title>Three Tier Web App</title></head>
              <body style="font-family: Arial; text-align: center; padding-top: 50px;">
                <h1 style="color: #28a745;">✅ Web Tier is Running Successfully!</h1>
                <h2>Instance ID: <span style="color: #007bff;">$(curl -s http://169.254.169.254/latest/meta-data/instance-id)</span></h2>
                <p>This instance is behind the Public ALB</p>
                <p><strong>Environment:</strong> Dev | <strong>Tier:</strong> Web</p>
              </body>
              </html>
              HTML

              systemctl restart nginx
              EOF

  tags = {
    Name        = "${var.project_name}-web-ec2-${count.index + 1}"
    Tier        = "Web"
    Environment = "dev"
  }
}

# Attach EC2 instances to ALB Target Group
resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_ec2[count.index].id
  port             = 80
}

output "web_ec2_public_ips" {
  value       = aws_instance.web_ec2[*].public_ip
  description = "Public IPs of Web EC2 Instances"
}