variable "project_name" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "app_sg_id" {
  type = string
}