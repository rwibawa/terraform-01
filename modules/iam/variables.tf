variable "project_name" {
  type        = string
  description = "Project name prefix for all resources"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "us-west-2"
}

##############################
# Networking
##############################
variable "cidr_block" {
  type        = string
  description = "VPC CIDR block"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs"
}

##############################
# Kinesis/Kafka
##############################
variable "kinesis_shard_count" {
  type        = number
  description = "Number of shards for Kinesis stream"
  default     = 2
}

##############################
# RDS
##############################
variable "db_username" {
  type        = string
  description = "Database username"
}

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

##############################
# EKS Auth
##############################
variable "eks_cluster_endpoint" {
  type        = string
  description = "EKS cluster API endpoint"
}

variable "eks_cluster_ca" {
  type        = string
  description = "EKS cluster CA certificate"
}

variable "eks_auth_token" {
  type        = string
  description = "Authentication token for EKS"
  sensitive   = true
}
