terraform {
  required_version = ">= 0.12.2"

  backend "s3" {
    region         = "eu-west-3"
    bucket         = "moq-test-buket-state"
    key            = "terraform.tfstate"
    dynamodb_table = "losho"
    profile        = ""
    role_arn       = ""
    encrypt        = "true"
  }
}


