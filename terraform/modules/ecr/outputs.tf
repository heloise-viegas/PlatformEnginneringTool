output "repository_urls" {
  description = "Map of service name to its ECR repository URL"
  value       = { for name, repo in aws_ecr_repository.this : name => repo.repository_url }
}
