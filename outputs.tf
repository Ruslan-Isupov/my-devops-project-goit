# --- Backend ---
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.s3_backend.dynamodb_table_name
}

# --- VPC ---
output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

# --- ECR ---
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

# --- EKS в---
output "eks_cluster_endpoint" {
  description = "EKS API endpoint"
  value       = module.eks.eks_cluster_endpoint  # <--- Було cluster_endpoint, стало eks_cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name      # <--- Було cluster_name, стало eks_cluster_name
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS Worker Nodes"
  value       = module.eks.eks_node_role_arn
}