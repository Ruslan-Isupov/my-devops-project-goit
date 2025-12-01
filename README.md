# 🚀 AWS Final Project: Full GitOps CI/CD Platform

This repository contains a production-ready Infrastructure as Code (IaC) solution deployed on **AWS EKS**.
It integrates **Jenkins** (CI), **Argo CD** (CD), and **Prometheus/Grafana** (Monitoring) to automate the deployment of a Django application.

---

## 🏗️ Project Architecture & Components

| Component              | Technology           | Description                                     |
| :--------------------- | :------------------- | :---------------------------------------------- |
| **Infrastructure**     | Terraform            | Manages VPC, EKS, RDS, ECR, IAM roles.          |
| **Kubernetes**         | AWS EKS              | Managed K8s cluster (3 nodes, t3.small).        |
| **Database**           | AWS RDS              | Universal module (Standard Postgres or Aurora). |
| **Container Registry** | AWS ECR              | Stores Docker images built by Jenkins.          |
| **CI (Build)**         | Jenkins              | Automates Docker build (Kaniko) & Git updates.  |
| **CD (Deploy)**        | Argo CD              | Syncs K8s manifests from Git to the cluster.    |
| **Monitoring**         | Prometheus & Grafana | Metrics collection and visualization.           |

### 📂 Directory Structure

```text
Project/
│
├── main.tf         # Головний файл для підключення модулів
├── backend.tf        # Налаштування бекенду для стейтів (S3 + DynamoDB
├── outputs.tf        # Загальні виводи ресурсів
│
├── modules/         # Каталог з усіма модулями
│  ├── s3-backend/     # Модуль для S3 та DynamoDB
│  │  ├── s3.tf      # Створення S3-бакета
│  │  ├── dynamodb.tf   # Створення DynamoDB
│  │  ├── variables.tf   # Змінні для S3
│  │  └── outputs.tf    # Виведення інформації про S3 та DynamoDB
│  │
│  ├── vpc/         # Модуль для VPC
│  │  ├── vpc.tf      # Створення VPC, підмереж, Internet Gateway
│  │  ├── routes.tf    # Налаштування маршрутизації
│  │  ├── variables.tf   # Змінні для VPC
│  │  └── outputs.tf  
│  ├── ecr/         # Модуль для ECR
│  │  ├── ecr.tf      # Створення ECR репозиторію
│  │  ├── variables.tf   # Змінні для ECR
│  │  └── outputs.tf    # Виведення URL репозиторію
│  │
│  ├── eks/           # Модуль для Kubernetes кластера
│  │  ├── eks.tf        # Створення кластера
│  │  ├── aws_ebs_csi_driver.tf # Встановлення плагіну csi drive
│  │  ├── variables.tf   # Змінні для EKS
│  │  └── outputs.tf    # Виведення інформації про кластер
│  │
│  ├── rds/         # Модуль для RDS
│  │  ├── rds.tf      # Створення RDS бази даних  
│  │  ├── aurora.tf    # Створення aurora кластера бази даних  
│  │  ├── shared.tf    # Спільні ресурси  
│  │  ├── variables.tf   # Змінні (ресурси, креденшели, values)
│  │  └── outputs.tf  
│  │ 
│  ├── jenkins/       # Модуль для Helm-установки Jenkins
│  │  ├── jenkins.tf    # Helm release для Jenkins
│  │  ├── variables.tf   # Змінні (ресурси, креденшели, values)
│  │  ├── providers.tf   # Оголошення провайдерів
│  │  ├── values.yaml   # Конфігурація jenkins
│  │  └── outputs.tf    # Виводи (URL, пароль адміністратора)
│  │ 
│  └── argo_cd/       # ✅ Новий модуль для Helm-установки Argo CD
│    ├── jenkins.tf    # Helm release для Jenkins
│    ├── variables.tf   # Змінні (версія чарта, namespace, repo URL тощо)
│    ├── providers.tf   # Kubernetes+Helm. переносимо з модуля jenkins
│    ├── values.yaml   # Кастомна конфігурація Argo CD
│    ├── outputs.tf    # Виводи (hostname, initial admin password)
│		  └──charts/         # Helm-чарт для створення app'ів
│ 	 	  ├── Chart.yaml
│	 	  ├── values.yaml     # Список applications, repositories
│			  └── templates/
│		    ├── application.yaml
│		    └── repository.yaml
├── charts/
│  └── django-app/
│    ├── templates/
│    │  ├── deployment.yaml
│    │  ├── service.yaml
│    │  ├── configmap.yaml
│    │  └── hpa.yaml
│    ├── Chart.yaml
│    └── values.yaml   # ConfigMap зі змінними середовища
└──Django
			 ├── app\
			 ├── Dockerfile
			 ├── Jenkinsfile
			 └── docker-compose.yaml

```

---

## 🚀 Quick Start Guide

### 1. Prerequisites

- **Terraform >= 1.5**
- **AWS CLI v2** configured
- **kubectl** installed

### 2. Deploy Infrastructure

Initialize Terraform (migrates state to S3 backend):

```bash
terraform init
```

Apply configuration (creates VPC, EKS, RDS, etc.):

```bash
terraform apply
```

_(Type `yes` when prompted. Deployment takes ~15-20 mins)._

### 3. Connect to EKS Cluster

Refresh your kubeconfig token to access the cluster:

```bash
aws eks --region eu-central-1 update-kubeconfig --name lesson-8-cluster
```

---

## 🔑 Access & Verification

### 🔹 1. Jenkins (CI)

Jenkins is exposed via LoadBalancer.

- **URL:** Get External IP via `kubectl get svc -n jenkins`
- **Login:** `admin`
- **Password:** `admin123`

**CI Flow:**

1.  Run **`seed-job`** (Configured via JCasC).
2.  Run **`django-pipeline`**.
3.  **Success:** Green build means the image is pushed to ECR and the Git tag is updated.

### 🔹 2. Argo CD (CD)

Argo CD automatically syncs changes from Git.

- **URL:** Get External IP via `kubectl get svc -n argocd`
- **Login:** `admin`
- **Get Password:**

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

**CD Flow:**

1.  Check the **`django-app`** tile.
2.  **Success:** Status should be **Synced (Green)** and **Healthy**.

### 🔹 3. Monitoring (Prometheus & Grafana)

Grafana is exposed via LoadBalancer.

- **URL:** Get External IP via `kubectl get svc -n monitoring`
- **Login:** `admin`
- **Password:** `admin123AWS23`

**Check Metrics:**

1.  Open **Dashboards -> Kubernetes / Compute Resources / Cluster**.
2.  Verify CPU/Memory usage graphs.

**Check Prometheus Targets:**

```bash
kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090:9090
```

Open [http://localhost:9090/targets](http://localhost:9090/targets).

---

## 💾 Universal RDS Module

This project features a custom Terraform module for database deployment.

| Feature       | Description                                                             |
| :------------ | :---------------------------------------------------------------------- |
| **Universal** | Switch between Standard RDS and Aurora using `use_aurora = true/false`. |
| **Secure**    | Deployed in private subnets with restricted Security Groups.            |
| **Flexible**  | Supports engine versioning and instance resizing.                       |

**Connection Output:**

```bash
terraform output rds_endpoint
```

---

## 🧹 Cleanup (Destroy)

To prevent AWS charges, destroy all resources after testing:

```bash
terraform destroy
```
