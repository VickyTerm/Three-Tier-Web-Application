terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

variable "project_name" {
  default = "three-tier-app"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "azs" {
  default = ["ap-south-1a", "ap-south-1b"]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"     # You can update to 6.6.1 later

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs = var.azs

  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets  = ["10.0.11.0/24", "10.0.12.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]

  create_database_subnet_group = true
  enable_nat_gateway           = true
  one_nat_gateway_per_az       = true      # This will create 2 NATs
  single_nat_gateway           = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = var.project_name
  }
}

# === Outputs ===
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "database_subnet_ids" {
  value = module.vpc.database_subnets
}

output "nat_gateway_ids" {
  value = module.vpc.natgw_ids
}