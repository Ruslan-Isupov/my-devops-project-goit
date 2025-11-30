# Кластер
resource "aws_rds_cluster" "aurora" {
  count              = var.use_aurora ? 1 : 0
  cluster_identifier = "${var.name}-cluster"
  
  engine             = var.engine_cluster
  engine_version     = var.engine_version_cluster
  
  database_name      = var.db_name
  master_username    = var.username
  master_password    = var.password
  port               = 5432

  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora[0].name
  
  backup_retention_period = try(tonumber(var.backup_retention_period), 7)
  skip_final_snapshot     = true

  tags = var.tags
}

# Головний інстанс (Writer)
resource "aws_rds_cluster_instance" "aurora_writer" {
  count              = var.use_aurora ? 1 : 0
  identifier         = "${var.name}-writer"
  cluster_identifier = aws_rds_cluster.aurora[0].id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.aurora[0].engine
  engine_version     = aws_rds_cluster.aurora[0].engine_version
  
  db_subnet_group_name = aws_db_subnet_group.default.name
  publicly_accessible  = var.publicly_accessible
  tags                 = var.tags
}

# Репліки (Readers)
resource "aws_rds_cluster_instance" "aurora_readers" {
  count              = var.use_aurora ? var.aurora_replica_count : 0
  identifier         = "${var.name}-reader-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora[0].id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.aurora[0].engine
  engine_version     = aws_rds_cluster.aurora[0].engine_version
  
  db_subnet_group_name = aws_db_subnet_group.default.name
  publicly_accessible  = var.publicly_accessible
  tags                 = var.tags
}

# Параметри
resource "aws_rds_cluster_parameter_group" "aurora" {
  count       = var.use_aurora ? 1 : 0
  name        = "${var.name}-aurora-pg"
  family      = var.parameter_group_family_aurora
  description = "Aurora Cluster Parameter Group"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = "pending-reboot"
    }
  }
  tags = var.tags
}