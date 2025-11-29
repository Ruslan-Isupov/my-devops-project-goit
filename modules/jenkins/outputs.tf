output "jenkins_release_name" {
  value = helm_release.jenkins.name
}

output "jenkins_namespace" {
  value = helm_release.jenkins.namespace
}
output "jenkins_url" {
  description = "URL to access Jenkins (might take a few minutes to appear)"
  # Складна конструкція, щоб не було помилки, якщо LoadBalancer ще не видав адресу
  value       = try("http://${helm_release.jenkins.metadata[0].name}.${helm_release.jenkins.namespace}.svc.cluster.local", "Wait for LoadBalancer IP")
}