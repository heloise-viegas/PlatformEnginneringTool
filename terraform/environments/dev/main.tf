locals {
  # modules/vpc expects maps keyed by AZ, not parallel lists.
  pub_subnets  = zipmap(var.azs, var.public_subnet_cidrs)
  priv_subnets = zipmap(var.azs, var.private_subnet_cidrs)
}

module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr
  pub_subnets  = local.pub_subnets
  priv_subnets = local.priv_subnets
}

# IAM roles (cluster role, node role, EBS CSI IRSA role) needed by the eks
# module below. oidc_issuer_url only exists after the cluster is created, so
# on a first-ever apply run `terraform apply -target=module.eks` first, then
# a full apply so the IRSA trust policies pick up the real issuer.
module "iam" {
  source = "../../modules/iam"

  project_name    = var.project_name
  environment     = var.environment
  cluster_name    = var.cluster_name
  oidc_issuer_url = module.eks.oidc_issuer_url
}

module "eks" {
  source = "../../modules/eks"

  project_name    = var.project_name
  environment     = var.environment
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  aws_region      = var.aws_region

  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids

  cluster_role_arn = module.iam.cluster_role_arn
  node_role_arn    = module.iam.node_role_arn
  ebs_csi_role_arn = module.iam.ebs_csi_role_arn

  node_instance_type = var.node_instance_types[0]
  node_desired_size  = var.node_desired_size
  node_min_size      = var.node_min_size
  node_max_size      = var.node_max_size
  node_disk_size     = var.node_disk_size
}
