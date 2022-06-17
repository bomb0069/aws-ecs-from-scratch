output "frontend-images-url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "backend-images-url" {
  value = aws_ecr_repository.backend.repository_url
}

output "database-images-url" {
  value = aws_ecr_repository.database.repository_url
}
