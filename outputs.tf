# --- VPC Outputs ---
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

# --- ECR Outputs ---
output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = module.ecr.repository_url
}

# --- EKS Outputs ---
# Ми звертаємось до МОДУЛЯ (module.eks), а не до ресурсу
output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.eks_cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_node_role_arn" {
  description = "Node Group Role ARN"
  value       = module.eks.eks_node_role_arn
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

# --- S3 Backend Output ---
output "s3_bucket_name" {
  value = module.s3_backend.s3_bucket_name
}