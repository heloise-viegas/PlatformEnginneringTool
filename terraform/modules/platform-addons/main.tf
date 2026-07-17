# Installs the Week 1 cluster add-ons: Argo CD, metrics-server, and (optionally)
# ingress-nginx. Assumes the calling root module has already configured the
# `helm` and `kubernetes` providers against the target EKS cluster.
#
# ingress-nginx is off by default (var.enable_ingress_nginx = false) since its
# Service provisions a billed AWS LoadBalancer. With it off, reach services via
# `kubectl port-forward svc/<name> 8080:80 -n <namespace>` instead.

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  # Chart defaults are fine to start; override via `set`/`values` blocks
  # as the platform's needs grow (SSO, ingress for the Argo CD UI, etc.).
}

resource "kubernetes_namespace" "ingress_nginx" {
  count = var.enable_ingress_nginx ? 1 : 0
  metadata {
    name = var.ingress_nginx_namespace
  }
}

resource "helm_release" "ingress_nginx" {
  count      = var.enable_ingress_nginx ? 1 : 0
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.ingress_nginx_chart_version
  namespace  = kubernetes_namespace.ingress_nginx[0].metadata[0].name

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.metrics_server_chart_version
  namespace  = var.metrics_server_namespace
}
