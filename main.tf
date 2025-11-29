terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"  # <--- ФІКСУЄМО ВЕРСІЮ, ЩОБ ПРИБРАТИ ПОМИЛКУ
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# --- 1. S3 Backend ---
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "gitops-state-risupov-lesson8"
  table_name  = "terraform-locks-8"
}

# --- 2. VPC ---
module "vpc" {
  source             = "./modules/vpc"
  vpc_name           = "lesson-8-vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

# --- 3. ECR ---
module "ecr" {
  source   = "./modules/ecr"
  ecr_name = "django-app-repo-8"
}

# --- 4. EKS ---
module "eks" {
  source       = "./modules/eks"
  cluster_name = "lesson-8-cluster"
  
  vpc_id       = module.vpc.vpc_id 
  subnet_ids   = module.vpc.public_subnet_ids

  # Налаштування нод
  node_group_name = "general"
  
 
  instance_type   = "t3.small" 
  
  desired_size    = 2
  max_size        = 3
  min_size        = 2
}

# --- НАЛАШТУВАННЯ HELM та KUBERNETES ---
data "aws_eks_cluster" "cluster" {
  name = module.eks.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.eks_cluster_name
}

# Провайдер для Helm (у вас вже є)
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# 👇 ДОДАЙТЕ ЦЕЙ БЛОК ОБОВ'ЯЗКОВО! 👇
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# --- 5. Jenkins ---
module "jenkins" {
  source            = "./modules/jenkins"
  cluster_name      = module.eks.eks_cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  github_pat      = var.github_pat
  github_user     = var.github_user
  github_repo_url = var.github_repo_url

  depends_on = [module.eks]

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}