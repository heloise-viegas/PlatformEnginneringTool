variable "argocd_chart_version" {
  description = "Helm chart version for Argo CD"
  type        = string
  default     = "7.7.11"
}

variable "enable_ingress_nginx" {
  description = "Install ingress-nginx. Its Service defaults to type LoadBalancer, which provisions a billed AWS ELB/NLB - leave this false to skip that cost and access services via kubectl port-forward instead. Flip to true whenever you actually need external HTTP access."
  type        = bool
  default     = false
}

variable "ingress_nginx_chart_version" {
  description = "Helm chart version for ingress-nginx"
  type        = string
  default     = "4.11.3"
}

variable "metrics_server_chart_version" {
  description = "Helm chart version for metrics-server"
  type        = string
  default     = "3.12.1"
}

variable "argocd_namespace" {
  description = "Namespace to install Argo CD into"
  type        = string
  default     = "argocd"
}

variable "ingress_nginx_namespace" {
  description = "Namespace to install ingress-nginx into"
  type        = string
  default     = "ingress-nginx"
}

variable "metrics_server_namespace" {
  description = "Namespace to install metrics-server into"
  type        = string
  default     = "kube-system"
}
