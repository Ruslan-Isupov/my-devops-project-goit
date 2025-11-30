output "endpoint" {
  description = "Connection endpoint"
  value = var.use_aurora ? join("", aws_rds_cluster.aurora[*].endpoint) : join("", aws_db_instance.standard[*].address)
}
output "port" { value = 5432 }