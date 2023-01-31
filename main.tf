terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

module "remote" {
  source = "./modules/remote"
  namespace  = "moq"
  stage      = "test"
  name       = "buket"
  attributes = ["state"]

  dynamodb_table_name = "losho"
  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
  force_destroy                      = true
}

module "ecr" {
  source = "./modules/ecr"
  
}
module "init-build" {
  source = "./modules/init-build"
  ecr_name = module.ecr.ecr_name
}

module "cluster" {
  source = "./modules/cluster"
  region = var.region
  Demo-type = var.Demo-type
  environment = var.environment
  private_subnet_cidr = var.private_subnet_cidr
  public_subnet_cidr = var.public_subnet_cidr
  cidr = var.cidr
  ecr_name = module.ecr.ecr_name
  depends_on = [
    module.ecr, module.init-build
  ]
}

module "codebuild" {
  source = "./modules/codebuild"
  vpc_id = module.cluster.vpc_id
   github_oauth_token = var.github_oauth_token 
  subnets = module.cluster.subnets
  depends_on = [
    module.cluster, module.init-build
  ]

}
