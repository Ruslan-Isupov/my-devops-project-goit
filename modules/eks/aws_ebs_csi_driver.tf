# --- 1. Отримуємо сертифікат динамічно (щоб не хардкодити хеш) ---
data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

# --- 2. Створюємо IAM OIDC Provider ---
resource "aws_iam_openid_connect_provider" "oidc" {
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  # Беремо хеш автоматично з data-source (це надійніше)
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}

# --- 3. IAM роль для EBS CSI Driver ---
resource "aws_iam_role" "ebs_csi_irsa_role" {
  name = "${var.cluster_name}-ebs-csi-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.oidc.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })
}

# --- 4. Прикріплюємо політику ---
resource "aws_iam_role_policy_attachment" "ebs_irsa_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_irsa_role.name
}

# --- 5. EKS Addon ---
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "aws-ebs-csi-driver"
  
  # Версію краще не фіксувати жорстко, нехай EKS вибере сумісну
  # addon_version            = "v1.41.0-eksbuild.1"
  
  service_account_role_arn = aws_iam_role.ebs_csi_irsa_role.arn
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [
    aws_iam_openid_connect_provider.oidc,
    aws_iam_role_policy_attachment.ebs_irsa_policy
  ]
}