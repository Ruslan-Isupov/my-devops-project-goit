variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

# 👇 ДОДАЄМО ЦЮ ЗМІННУ, БО ВОНА ВИКОРИСТОВУЄТЬСЯ В MAIN.TF
variable "vpc_id" {
  description = "VPC ID where the cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

# --- Змінні для Node Group ---
variable "node_group_name" {
  description = "Name of the node group"
  type        = string
  default     = "general"
}

variable "instance_type" {
  description = "EC2 instance type for the worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "desired_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}