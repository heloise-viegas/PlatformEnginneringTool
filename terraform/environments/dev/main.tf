locals {
  tags = merge(var.tags, { Environment = var.environment })
}

module "vpc" {
  source = "../../modules/vpc"

  name                 = "${var.cluster_name}-${var.environment}"
  cluster_name         = var.cluster_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name         = var.cluster_name
  cluster_version      = var.cluster_version
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  public_subnet_ids    = module.vpc.public_subnet_ids
  node_instance_types  = var.node_instance_types
  node_desired_size    = var.node_desired_size
  node_min_size        = var.node_min_size
  node_max_size        = var.node_max_size
  tags                 = local.tags
}

# Platform add-ons (Argo CD, ingress-nginx, metrics-server) require the
# `helm`/`kubernetes` providers configured in provider.tf, which read the
# cluster's endpoint/CA/token via the aws_eks_cluster_auth data source below.
# On a first-ever apply, run `terraform apply -target=module.eks` first so the
# cluster exists before Terraform tries to talk to its Kubernetes API.
module "platform_addons" {
  source = "../../modules/platform-addons"

  depends_on = [module.eks]
}
