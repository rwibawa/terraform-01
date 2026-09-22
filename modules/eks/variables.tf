variable "project_name" {
  type        = string
  description = "Project name prefix for all EKS resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for EKS cluster"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for EKS nodes"
}

variable "cluster_role_arn" {
  type        = string
  description = "IAM role ARN for EKS cluster"
}

variable "node_role_arn" {
  type        = string
  description = "IAM role ARN for EKS node group"
}

variable "desired_size" {
  type        = number
  description = "Desired number of EKS nodes"
  default     = 3
}

variable "min_size" {
  type        = number
  description = "Minimum number of EKS nodes"
  default     = 3
}

variable "max_size" {
  type        = number
  description = "Maximum number of EKS nodes"
  default     = 10
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for EKS nodes"
  default     = "m5.large"
}
