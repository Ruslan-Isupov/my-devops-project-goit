AWS Cloud Infrastructure (Lesson 5)
This repository implements an Infrastructure as Code (IaC) solution using Terraform to provision a scalable and secure environment on AWS. The project follows best practices, including modular design and remote state management.

📂 Project Structure
The project is organized into logical modules to ensure maintainability and reusability:

Plaintext

lesson-5/
├── main.tf # Entry point: Orchestrates all modules
├── backend.tf # Remote backend configuration (S3 + DynamoDB)
├── outputs.tf # Global infrastructure outputs
│
├── modules/ # Local modules directory
│ ├── vpc/ # Networking layer (VPC, Subnets, Routing, NAT/IGW)
│ ├── ecr/ # Artifact layer (Elastic Container Registry)
│ └── s3-backend/ # State layer (S3 Bucket + DynamoDB Lock)
│
└── README.md # Documentation
🏗 Architecture Components

1. State Management (modules/s3-backend)
   Sets up a robust backend for Terraform state files:

S3 Bucket: Stores the terraform.tfstate file with versioning enabled for recovery.

DynamoDB Table: Handles state locking to prevent concurrent modifications.

2. Networking (modules/vpc)
   Deploys a completely isolated network environment:

VPC: Custom Virtual Private Cloud with a specific CIDR block.

Subnets: Segregated into Public (Internet-facing) and Private (Internal) subnets across multiple Availability Zones.

Gateways: Internet Gateway for public access and NAT Gateway for secure outbound traffic from private subnets.

3. Container Registry (modules/ecr)
   Provisions a private registry for Docker images:

Security: Image scanning on push is enabled to detect vulnerabilities.

Lifecycle: Managed repository for application artifacts.

🚀 Deployment Guide
Prerequisites
Terraform (v1.0+) installed.

AWS CLI installed and configured.

Valid AWS credentials (aws configure).

Step 1: Initialization
Navigate to the project directory and initialize Terraform. This downloads the necessary providers and initializes the backend.

Bash

cd lesson-5
terraform init
Step 2: Plan
Generate an execution plan to preview the infrastructure changes without applying them.

Bash

terraform plan
Step 3: Apply
Provision the infrastructure in your AWS account.

Bash

terraform apply
(Type yes when prompted to confirm).

🧹 Cleanup (Destroy)
To remove all resources created by this project and avoid incurring AWS costs, run:

Bash

terraform destroy
📋 Key Outputs
After a successful deployment, Terraform will output the following information:

vpc_id: The ID of the created Virtual Private Cloud.

ecr_repository_url: The URL for pushing/pulling Docker images.

s3_bucket_name: The name of the bucket storing the Terraform state.
