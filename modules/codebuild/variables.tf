variable "vpc_id" {
  
}
variable "github_oauth_token" {
  
}

variable "environment" {
  type  = string
}

variable "app_name" {
  type  = string
}

locals {
  codebuild_project_name = "${var.app_name}-${var.environment}"
  description = "Codebuild for ${var.app_name} environment ${var.environment}"
}

variable "repo_url" {
  default = "https://github.com/ilianvo/Final-Demo"
}

variable "subnets" {
  
}

variable "build_spec_file" {
  default = "modules/codebuild/buildspec.yml"
}

variable "branch_pattern" {
  default = "main"
}

variable "git_trigger_event" {
  default = "PUSH"
}
