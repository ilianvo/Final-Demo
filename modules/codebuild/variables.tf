variable "vpc_id" {
  
}
variable "github_oauth_token" {
  
}

locals {
  codebuild_project_name = "This-Build"
  description = "Codebuild-for-Me"
}

variable "repo_url" {
  default = "https://github.com/ilianvo/Final-Demo"
}

variable "subnets" {
  
}

variable "build_spec_file" {
  default = ""modules/codebuild/buildspec.yml""
}

variable "branch_pattern" {
  default = "main"
}

variable "git_trigger_event" {
  default = "PUSH"
}
