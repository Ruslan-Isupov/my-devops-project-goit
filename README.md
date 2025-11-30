# 🚀 AWS GitOps CI/CD Pipeline: Jenkins, Kaniko, Argo CD (Lesson 8)

This repository contains a modular Terraform configuration for deploying a complete CI/CD pipeline on **AWS EKS** using the **GitOps** approach.

Our solution ensures automatic **Docker image building** (Kaniko), its **publication to Amazon ECR**, and **continuous deployment** to Kubernetes using Argo CD.

## 1. 📁 Project Structure & Setup

| Directory / File | Purpose |
| :--- | :--- |
| `main.tf` | Root configuration. Calls EKS, Jenkins, and Argo CD modules. |
| `modules/jenkins/` | Installs Jenkins via Helm. Configures **IRSA** and stability probes. |
| `modules/argo_cd/` | Installs Argo CD and sets up the **Application** resource. |
| `charts/django-app/` | Helm chart for the Django application. |
| **`Jenkinsfile`** | **CI Pipeline Script:** Defines the build, ECR push, and Git tag update logic. |
| `backend.tf` | Defines the remote state storage (S3 + DynamoDB for locking). |

***

## 2. 🚀 Deployment and Execution

### A. Core Infrastructure Deployment (Terraform)

All commands should be run from the root directory (`lesson-8`).

| Step | Command | Description |
| :--- | :--- | :--- |
| **1. Initialize** | `terraform init` | Downloads providers and **migrates local state to S3**. |
| **2. Apply** | `terraform apply` | Creates/Updates all cloud and Kubernetes resources (EKS, Jenkins, Argo CD). |
| **3. Destroy** | `terraform destroy` | **Removes all AWS resources.** (**CRITICAL** for cost management). |

### B. EKS Access and Monitoring

The EKS token expires every 15 minutes. Always refresh it before using `kubectl`:

```bash
aws eks --region eu-central-1 update-kubeconfig --name lesson-8-cluster
```

***

## 3. ✅ Verification (CI/CD Flow Check)

### 🔑 Jenkins Job Check (CI Verification)

1.  **Run Main Pipeline:** The **`django-pipeline`** runs the complete CI process.
2.  **Result:** The pipeline will build the Docker image and, in the final stage (`Update Chart Tag in Git`), it will **commit the new image tag** to the `lesson-8-9` branch.

### 🌐 Argo CD Verification (CD Check)

This verifies the GitOps deployment is working automatically.

1.  **Access Argo CD:** Use the LoadBalancer URL or `kubectl port-forward svc/argocd-server -n argocd 8081:443`.
2.  **Credentials:** `admin` / `Password retrieved via kubectl`
3.  **Final Result:** The **`django-app`** tile must automatically change to **`Synced`** and **`Healthy`** after Jenkins pushes the new tag to Git.

---

## 📝 Key GitOps Configuration Details

| Parameter | Value / Location | Description |
| :--- | :--- | :--- |
| **Git Repository** | `https://github.com/Ruslan-Isupov/goit-devops.git` | Source of truth for both Jenkins and Argo CD. |
| **Target Branch** | `lesson-8-9` | The branch used for all CI/CD operations. |
| **ECR Registry** | `155466261957.dkr.ecr.eu-central-1.amazonaws.com` | Destination for the built Docker image. |
| **K8s Service Account** | `jenkins-sa` | Annotated with the IRSA role for ECR access. |

### 🔑 Access Commands

| Service | Command for Password / Address |
| :--- | :--- |
| **Argo CD Password** | `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo` |
| **Argo CD URL** | `kubectl get svc -n argocd` (Look for EXTERNAL-IP for `argocd-server`) |
| **Jenkins Login** | **admin** / **admin123** |

