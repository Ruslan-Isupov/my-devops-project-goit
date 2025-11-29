#variable "kubeconfig" {
  #description = "Шлях до kubeconfig файлу"
  #type        = string
#}

#variable "cluster_name" {
  #description = "Назва Kubernetes кластера"
  #type        = string
#}
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC Provider for IRSA"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token"
  type        = string
}

variable "github_user" {
  description = "GitHub Username"
  type        = string
}

variable "github_repo_url" {
  description = "Repository URL containing the Helm chart or application"
  type        = string
}