variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "shard_count" {
  type        = number
  description = "Number of Kinesis shards"
  default     = 2
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnets for MSK brokers"
}

variable "security_group_id" {
  type        = string
  description = "Security group for MSK"
}

variable "broker_instance_type" {
  type        = string
  description = "MSK broker instance type"
  default     = "kafka.m5.large"
}

variable "broker_nodes" {
  type        = number
  description = "Number of MSK broker nodes"
  default     = 3
}
