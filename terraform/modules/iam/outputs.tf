output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.cluster.arn
}

output "node_role_arn" {
  description = "ARN of the EKS node group IAM role"
  value       = aws_iam_role.node.arn
}

output "fluent_bit_role_arn" {
  description = "ARN of the Fluent Bit IRSA role — annotate the fluent-bit ServiceAccount with this"
  value       = aws_iam_role.fluent_bit.arn
}

output "ebs_csi_role_arn" {
  description = "ARN of the EBS CSI driver IRSA role"
  value       = aws_iam_role.ebs_csi.arn
}

