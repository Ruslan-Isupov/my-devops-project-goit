output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "eks_node_role_arn" {
  # Переконайтеся, що в node.tf ресурс називається "nodes"
  value = aws_iam_role.nodes.arn
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.oidc.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.oidc.url
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}
