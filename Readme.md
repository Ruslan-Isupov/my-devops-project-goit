☁️ AWS EKS Infrastructure Project (Lesson 7)
This repository contains a modular Infrastructure as Code (IaC) configuration using Terraform to deploy a production-ready Kubernetes environment on AWS. It also includes a Helm chart for deploying a containerized Django application with auto-scaling capabilities.
lesson-7/
├── main.tf # Root configuration & module calls
├── outputs.tf # Global outputs (VPC ID, ECR URL, Cluster Endpoint)
├── backend.tf # Remote backend configuration (S3 + DynamoDB)
├── modules/
│ ├── s3-backend/ # Terraform state storage & locking
│ ├── vpc/ # Networking (Public/Private Subnets, IGW, NAT)
│ ├── ecr/ # Elastic Container Registry
│ └── eks/ # Kubernetes Cluster & Node Groups
│
├── charts/
│ └── django-app/ # Helm Chart for the application
│ ├── templates/
│ │ ├── deployment.yaml
│ │ ├── service.yaml
│ │ ├── hpa.yaml
│ │ └── configmap.yaml
│ ├── values.yaml # Default configuration
│ └── Chart.yaml
│
└── README.md # Documentation

Module,Description
s3-backend,"Creates an S3 bucket with versioning and encryption for terraform.tfstate, plus a DynamoDB table for state locking."
vpc,"Deploys a VPC in eu-central-1 with 3 Public and 3 Private subnets, Route Tables, and Internet Gateway."
ecr,Provisions a private Elastic Container Registry (ECR) with image scanning enabled (scan_on_push).
eks,Deploys an AWS EKS Cluster (Control Plane) and a Managed Node Group (Worker Nodes) with necessary IAM roles.

🚀 Deployment Guide
Prerequisites
Terraform

AWS CLI

kubectl

Helm

Docker

Phase 1: Infrastructure (Terraform)
Initialize Terraform:

Bash

terraform init
Review the Plan:

Bash

terraform plan
Apply Configuration:

Bash

terraform apply
(Type yes when prompted. EKS creation takes ~15-20 mins).

Phase 2: Docker & ECR Workflow
Login to ECR: Replace <AWS_ACCOUNT_ID> with your ID (found in Terraform outputs or AWS Console).

Bash

aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.eu-central-1.amazonaws.com
Build & Tag Image: Navigate to your Django app directory.

Bash

docker build --platform linux/amd64 -t django-app .
docker tag django-app:latest <AWS_ACCOUNT_ID>.dkr.ecr.eu-central-1.amazonaws.com/lesson-7-ecr:latest
Push to Cloud:

Bash

docker push <AWS_ACCOUNT_ID>.dkr.ecr.eu-central-1.amazonaws.com/lesson-7-ecr:latest
Phase 3: Kubernetes & Helm
Connect kubectl to EKS:

Bash

aws eks update-kubeconfig --region eu-central-1 --name eks-cluster-demo
Deploy Application using Helm:

Bash

helm install my-django ./charts/django-app
Verify Deployment: Get the Load Balancer URL:

Bash

kubectl get svc
(Copy the EXTERNAL-IP and open it in your browser).

⚙️ Helm Chart Features
Deployment: Runs Django containers (replica count defined in values.yaml).

Service: Type LoadBalancer to expose the app to the internet.

HPA: Horizontal Pod Autoscaler scales pods (min: 2, max: 6) if CPU usage > 70%.

ConfigMap: Injects environment variables (ALLOWED_HOSTS, DEBUG, etc.) into containers.

🧹 Cleanup (Save Money!)
To avoid unexpected AWS charges, destroy resources in this order:

Remove Application:

Bash

helm uninstall my-django
Destroy Infrastructure:

Bash

terraform destroy
(Type yes to confirm).
