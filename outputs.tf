# =============================
#   Main Outputs
# =============================

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnets
  description = "Public Subnets IDs (Web Tier)"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnets
  description = "Private Subnets IDs (App Tier)"
}

output "database_subnet_ids" {
  value       = module.vpc.database_subnets
  description = "Database Subnets IDs"
}

output "nat_gateway_ids" {
  value       = module.vpc.natgw_ids
  description = "NAT Gateway IDs"
}

# Security Groups Outputs
output "sg_alb_public_id" {
  value       = aws_security_group.alb_public.id
  description = "Public ALB Security Group ID"
}

output "sg_web_ec2_id" {
  value       = aws_security_group.web_ec2.id
  description = "Web EC2 Security Group ID"
}

output "sg_alb_internal_id" {
  value       = aws_security_group.alb_internal.id
  description = "Internal ALB Security Group ID"
}

output "sg_app_ec2_id" {
  value       = aws_security_group.app_ec2.id
  description = "App EC2 Security Group ID"
}

output "sg_rds_id" {
  value       = aws_security_group.rds.id
  description = "RDS MySQL Security Group ID"
}