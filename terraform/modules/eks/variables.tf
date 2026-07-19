variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  description = "Public subnets — used for control plane ENIs and public LBs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnets — worker nodes placed here only"
  type        = list(string)
}

variable "cluster_role_arn" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "node_instance_type" {
  type = string
}

variable "node_desired_size" {
  type = number
}

variable "node_min_size" {
  type = number
}

variable "node_max_size" {
  type = number
}

variable "node_disk_size" {
  type = number
}

variable "ebs_csi_role_arn" {
  description = "IRSA role ARN for the EBS CSI driver — allows it to create/attach EBS volumes"
  type        = string
}
