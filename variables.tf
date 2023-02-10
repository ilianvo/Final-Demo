variable "private_subnet_cidr"{

}

variable "public_subnet_cidr" {
  
}

variable "cidr" {
  
}

variable "region" {
  
}

variable "app_name" {
  
}

variable "environment" {
  
}
variable "github_oauth_token" {
 type        = string
  sensitive   = true
  default     = ""
}


variable "image_tag" {
  type = string
}


variable "working_dir" {
  type        = string
  default     = ""
  description = "The path to the working directory (Makefile location)."
}