resource "aws_ecr_repository" "example" {
  name = "my-image"
  force_delete = true
}