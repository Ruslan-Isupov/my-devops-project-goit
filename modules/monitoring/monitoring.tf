resource "helm_release" "prometheus_monitoring" {
  name             = "prometheus"
  namespace        = var.namespace
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.prometheus_chart_version
  create_namespace = true
  
  timeout          = 1200  # Даємо йому 20 хвилин! (було 300 або 600)
  wait             = true
  # ---------------------------

  
  set {
    name  = "prometheusOperator.admissionWebhooks.enabled"
    value = "false"
  }
  set {
    name  = "prometheusOperator.tls.enabled"
    value = "false"
  }
  set {
    name  = "server.persistentVolume.enabled"
    value = "false"
  }
  set {
    name  = "alertmanager.persistentVolume.enabled"
    value = "false"
  }
  set {
    name  = "grafana.service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "grafana.adminPassword"
    value = var.grafana_password
  }
}