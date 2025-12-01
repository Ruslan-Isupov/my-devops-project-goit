output "grafana_password" {
  description = "Grafana Admin Password"
  value       = var.grafana_password
}

output "grafana_service_name" {
  value = "prometheus-stack-grafana"
}