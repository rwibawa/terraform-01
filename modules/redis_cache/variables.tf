// modules/redis_cache/variables.tf
variable "project_name" {
  type        = string
  description = "Project name prefix for Redis"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for Redis"
}

variable "node_type" {
  type        = string
  description = "Redis node type"
  default     = "cache.m5.large"
}

variable "num_nodes" {
  type        = number
  description = "Number of Redis nodes"
  default     = 3
}
