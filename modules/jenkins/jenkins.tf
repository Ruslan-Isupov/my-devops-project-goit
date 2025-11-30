# modules/jenkins/jenkins.tf

# --- 1. Storage Class (Для дисків Jenkins) ---
resource "kubernetes_storage_class_v1" "ebs_sc" {
  metadata {
    name = "ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    type = "gp3"
  }
}

# --- 2. IAM Роль для Jenkins  ---
resource "aws_iam_role" "jenkins_kaniko_role" {
  name = "${var.cluster_name}-jenkins-kaniko-role"

  # Trust Policy
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = var.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            # Дозволяємо доступ тільки конкретному Service Account у namespace jenkins
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:jenkins:jenkins-sa"
          }
        }
      }
    ]
  })
}

# --- 3. ECR (Permissions) ---
resource "aws_iam_role_policy" "jenkins_ecr_policy" {
  name = "${var.cluster_name}-jenkins-kaniko-ecr-policy"
  role = aws_iam_role.jenkins_kaniko_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:CreateRepository" # Додали на всяк випадок, якщо репо ще немає
        ],
        Resource = "*"
      }
    ]
  })
}

# --- 4. Service Account ( Kubernetes і AWS IAM) ---
resource "kubernetes_service_account" "jenkins_sa" {
  metadata {
    name      = "jenkins-sa"
    namespace = "jenkins"
    annotations = {
      # Ця анотація каже EKS: "Дай цьому акаунту права IAM ролі"
      "eks.amazonaws.com/role-arn" = aws_iam_role.jenkins_kaniko_role.arn
    }
  }

  
  depends_on = [
    helm_release.jenkins
  ]
}

# --- 5. Jenkins через Helm ---
resource "helm_release" "jenkins" {
  name             = "jenkins"
  namespace        = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = "5.8.27"
  create_namespace = true
  timeout          = 1200 # 20 хвилин чекаємо запуску

  values = [
    file("${path.module}/values.yaml")
  ]

 
  
  set {
    name  = "controller.startupProbe.failureThreshold"
    value = "30"
  }
  set {
    name  = "controller.startupProbe.periodSeconds"
    value = "10"
  }
  set {
    name  = "controller.livenessProbe.initialDelaySeconds"
    value = "180"
  }
  set {
    name  = "controller.livenessProbe.failureThreshold"
    value = "5"
  }
}