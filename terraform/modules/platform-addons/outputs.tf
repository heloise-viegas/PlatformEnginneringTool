output "argocd_namespace" {
  description = "Namespace Argo CD was installed into"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "ingress_nginx_namespace" {
  description = "Namespace ingress-nginx was installed into, null if enable_ingress_nginx is false"
  value       = var.enable_ingress_nginx ? kubernetes_namespace.ingress_nginx[0].metadata[0].name : null
}
