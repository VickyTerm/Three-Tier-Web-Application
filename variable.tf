variable "project_name" {
  default = "three-tier-app"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "azs" {
  default = ["ap-south-1a", "ap-south-1b"]
}