terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      #version = "~> 4.0"
      version = "4.50.0"
    }
  }
}

/*module "remote" {
  source = "./modules/remote"
  namespace  = "moq"
  stage      = "test"
  name       = "buket"
  attributes = ["state"]

  dynamodb_table_name = "losho"
  terraform_backend_config_file_path = ""
  terraform_backend_config_file_name = "backend.tf"
  force_destroy                      = true
}*/

module "remote-state" {
  source = "./modules/remote-state"
  
  s3_bucket_name = "final-demo-test-app"
  dynamodb_table_name = "final-demo-test-app-lock"
  terraform_backend_config_file_path = ""
  terraform_backend_config_file_name = "backend.tf"
  force_destroy = true
  terraform_state_file = "terraform.state"
}


module "ecr" {
  source = "./modules/ecr"
  environment = var.environment
  app_name    = var.app_name
  force_delete = true
}
module "init-build" {
  source = "./modules/init-build"
  region = var.region
  ecr_repository_url = module.ecr.ecr_repository_url
  environment = var.environment
  app_name = var.app_name
  working_dir = "${path.root}/app"
  image_tag = var.image_tag
  depends_on = [
    module.ecr,
  ]
  }

module "cluster" {
  source = "./modules/cluster"
  region = var.region
  app_name = var.app_name
  environment = var.environment
  private_subnet_cidr = var.private_subnet_cidr
  public_subnet_cidr = var.public_subnet_cidr
  cidr = var.cidr
  ecr_repository_url = module.ecr.ecr_repository_url
  image_tag   = var.image_tag
  depends_on = [
    module.ecr, module.init-build
  ]
}

module "codebuild" {
  source = "./modules/codebuild"
  environment = var.environment
  app_name = var.app_name
  vpc_id = module.cluster.vpc_id
   github_oauth_token = var.github_oauth_token 
  subnets = module.cluster.subnets
  depends_on = [
    module.cluster, module.init-build
  ]

}
