 terraform {
 backend "s3" {
    region         = "eu-west-3"
    bucket         = "final-demo-test-app"
    key            = "terraform.state"
    dynamodb_table = "final-demo-test-app-lock"
    encrypt        = "true"
  }
}

