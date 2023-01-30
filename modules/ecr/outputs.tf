output "ecr_name" {
  value = aws_ecr_repository.example.repository_url
}