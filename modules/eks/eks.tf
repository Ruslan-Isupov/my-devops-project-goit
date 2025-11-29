resource "aws_iam_role" "eks" {
  name = "${var.cluster_name}-eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

  role = aws_iam_role.eks.name
}

resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name

  role_arn = aws_iam_role.eks.arn
  
  vpc_config {
    endpoint_private_access = true   # Включає приватний доступ до API-сервера
    endpoint_public_access  = true   # Включає публічний доступ до API-сервера
    subnet_ids = var.subnet_ids      # Список підмереж, де буде працювати EKS
  }

  access_config {
    authentication_mode                         = "API"  # Автентифікація через API
    bootstrap_cluster_creator_admin_permissions = true   # Надає адміністративні права користувачу, який створив кластер
  }

  depends_on = [aws_iam_role_policy_attachment.eks]
}

