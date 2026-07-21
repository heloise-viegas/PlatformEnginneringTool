# One ECR repository per entry in var.service_names. Note: reference-service's
# repo ("reference-ecr") was created manually before this module existed and
# is intentionally NOT included here - importing it is a separate task.
# Every service scaffolded from here on gets its repo through this module
# instead, named after the service itself.

resource "aws_ecr_repository" "this" {
  for_each = toset(var.service_names)

  name                 = each.key
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Service     = each.key
  }
}

# Keep untagged images (from failed/superseded builds) from accumulating
# indefinitely.
resource "aws_ecr_lifecycle_policy" "expire_untagged" {
  for_each   = aws_ecr_repository.this
  repository = each.value.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expire untagged images after 14 days"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 14
      }
      action = { type = "expire" }
    }]
  })
}
