data "aws_region" "current" {}

resource "aws_security_group" "codebuild_sg" {
  name        = "allow_vpc_connectivity"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "import_source_credentials" {

  
  triggers = {
    github_oauth_token = var.github_oauth_token
  }

  provisioner "local-exec" {
    command = "${file("./modules/codebuild/cred_script.sh")}"
  }
}

# CodeBuild Project
resource "aws_codebuild_project" "project" {
  depends_on = [null_resource.import_source_credentials]
  name = local.codebuild_project_name
  description = local.description
  build_timeout = "120"
  service_role = aws_iam_role.role.arn

  artifacts {
    type = "NO_ARTIFACTS"
}

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:4.0"
    type = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name = "CI"
      value = "true"
    }
  }

  source {
    buildspec = var.build_spec_file
    type = "GITHUB"
    location = var.repo_url
    git_clone_depth = 1
    report_build_status = "true"
  }
 source_version = var.branch_pattern

  logs_config {
    cloudwatch_logs {
      group_name  = "codebuild-test-log-group"
      stream_name = "codebuild-test-log-stream"
      status      = "ENABLED"
    }
  }
  vpc_config {
    vpc_id = var.vpc_id

    subnets = var.subnets

    security_group_ids = [ aws_security_group.codebuild_sg.id ]
  }
}

resource "aws_codebuild_webhook" "develop_webhook" {
  project_name = aws_codebuild_project.project.name


  filter_group {
    filter {
      type = "EVENT"
      pattern = var.git_trigger_event
    }

    filter {
      type = "HEAD_REF"
      pattern = var.branch_pattern
    }
  }
}