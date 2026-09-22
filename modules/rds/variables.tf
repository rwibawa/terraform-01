variable "project_name" {
  type        = string
  description = "Project name prefix for RDS resources"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for RDS"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for RDS instance"
}

variable "db_username" {
  type        = string
  description = "Database username"
}

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.m5.large"
}

variable "storage_gb" {
  type        = number
  description = "Allocated storage in GB"
  default     = 100
}

variable "max_storage_gb" {
  type        = number
  description = "Max allocated storage in GB"
  default     = 500
}
