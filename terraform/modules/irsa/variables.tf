variable "role_name" {
  description = "Name of the IAM role to create"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the cluster's IAM OIDC provider (from the eks module output)"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL without the https:// prefix stripped automatically (pass the raw issuer, e.g. eks module's oidc_issuer_url output)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace of the service account this role is bound to"
  type        = string
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account this role is bound to"
  type        = string
}

variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Extra tags applied to the role"
  type        = map(string)
  default     = {}
}
