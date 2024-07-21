terraform {
 backend "s3" {
    region         = "eu-west-3"
    bucket         = "final-demo-test-pipeapp"
    key            = "terraform.state"
    dynamodb_table = "final-demo-test-pipeapp-lock"
    encrypt        = "true"
  }
}
