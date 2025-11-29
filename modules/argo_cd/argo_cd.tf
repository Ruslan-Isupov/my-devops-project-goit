# 1. Встановлення самого Argo CD
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.46.0"
  timeout          = 600

  values = [
    file("${path.module}/values.yaml")
  ]
}

# 2. Встановлення налаштувань (App of Apps)
resource "helm_release" "argo_apps" {
  name      = "argocd-apps"
  chart     = "${path.module}/charts" # Шлях до локальної папки charts всередині модуля
  namespace = "argocd"

  # Передаємо файл зі змінними (посилання на репозиторій)
  values = [
    file("${path.module}/charts/values.yaml")
  ]

  depends_on = [helm_release.argocd]
}