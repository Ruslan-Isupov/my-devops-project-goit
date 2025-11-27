resource "aws_ecr_repository" "main" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE" # Дозволяє перезаписувати теги (наприклад, latest)

  # Налаштування сканування вразливостей при завантаженні
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name = var.ecr_name
  }
}