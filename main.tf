module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs = var.azs

  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets  = ["10.0.11.0/24", "10.0.12.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
  single_nat_gateway     = false

  create_database_subnet_group = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = var.project_name
  }
}
module "rds" {
  source = "./modules/rds"

  project_name = var.project_name
  db_subnet_ids = module.vpc.database_subnets
  vpc_id = module.vpc.vpc_id

  app_sg_id = aws_security_group.app_ec2.id
}