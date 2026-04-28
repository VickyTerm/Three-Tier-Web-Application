# =============================
#   Security Groups - Updated
# =============================

# 1. Public ALB Security Group
resource "aws_security_group" "alb_public" {
  name        = "${var.project_name}-alb-public"
  description = "Security group for Public Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-alb-public"
    Tier        = "Public-ALB"
    Environment = "dev"
  }
}

# 2. Web Tier EC2 Security Group (Nginx)
resource "aws_security_group" "web_ec2" {
  name        = "${var.project_name}-web-ec2"
  description = "Security group for Web tier EC2 instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_public.id]
    description     = "Allow traffic from Public ALB"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["106.214.2.172/32"]   # Your IP only
    description = "Allow SSH from my IP only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-web-ec2"
    Tier        = "Web"
    Environment = "dev"
  }
}

# 3. Internal ALB Security Group
resource "aws_security_group" "alb_internal" {
  name        = "${var.project_name}-alb-internal"
  description = "Security group for Internal ALB (App tier)"
  vpc_id      = module.vpc.vpc_id

  # Allow Web Tier to Internal ALB on port 80 (Listener Port)
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_ec2.id]
    description     = "Allow HTTP from Web tier EC2 to Internal ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-alb-internal"
    Tier        = "Internal-ALB"
    Environment = "dev"
  }
}

# 4. App Tier EC2 Security Group (Node.js)
resource "aws_security_group" "app_ec2" {
  name        = "${var.project_name}-app-ec2"
  description = "Security group for App tier EC2 instances"
  vpc_id      = module.vpc.vpc_id

  # Allow Internal ALB to reach Node.js app on port 8080
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_internal.id]
    description     = "Allow Internal ALB to App EC2 on 8080"
  }

  # Optional: SSH access (restricted to your IP)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["106.214.2.172/32"]   # Your current IP
    description = "Allow SSH from my IP only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-app-ec2"
    Tier        = "App"
    Environment = "dev"
  }
}
