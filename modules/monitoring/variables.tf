variable "namespace" {
  description = "K8s namespace for monitoring"
  type        = string
  default     = "monitoring"
}

variable "grafana_chart_version" {
  description = "Version of Grafana chart"
  type        = string
  default     = "8.5.1"
}

variable "prometheus_chart_version" {
  description = "Version of Prometheus chart"
  type        = string
  default     = "56.6.0" # <--- ВИПРАВЛЕНО
}

# --- ОБОВ'ЯЗКОВО ДОДАЙТЕ ЦІ ДВІ ЗМІННІ ---

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "grafana_password" {
  description = "Password for Grafana admin"
  type        = string
}