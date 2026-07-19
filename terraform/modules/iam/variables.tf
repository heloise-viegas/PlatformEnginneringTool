variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL from the EKS cluster (used to create IRSA trust policies)"
  type        = string
}
