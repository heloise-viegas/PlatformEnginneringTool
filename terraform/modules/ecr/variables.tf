variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "service_names" {
  description = "Services that get their own ECR repository. The scaffold-service GitHub Actions workflow appends to this list (via terraform.tfvars) whenever a developer scaffolds a new service - run `terraform apply` after merging a scaffold PR to actually create the repo."
  type        = list(string)
  default     = []
}
