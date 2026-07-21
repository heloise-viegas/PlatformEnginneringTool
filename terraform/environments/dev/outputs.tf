output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  description = "Pass this into future irsa module instances for Weeks 4-6 add-ons"
  value       = module.eks.oidc_provider_arn
}

output "ecr_repository_urls" {
  description = "Map of service name to its ECR repository URL, for services registered in var.service_names"
  value       = module.ecr.repository_urls
}

output "configure_kubectl" {
  description = "Command to update your local kubeconfig once the cluster exists"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
