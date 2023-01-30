variable "region" {
  
}

variable "app_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cidr" {
}

variable "private_subnet_cidr" {
  type = list(string)
}

variable "public_subnet_cidr" {
  type = list(string)
}

variable "ecr_repository_url" {
  
}
locals {
  allowed_ports = [80, 443,8888,5000]
}


variable "image_tag" {
  type = string
}

locals {
  image = format("%s:%s", var.ecr_repository_url, var.image_tag)
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "TaskExecutionRole"
}
variable "ecs_task_role_name" {
  description = "ECS task role name"
  default = "TaskRole"
}