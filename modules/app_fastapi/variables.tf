variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace"
  default     = "app"
}

variable "helm_repo" {
  type        = string
  description = "Helm repository URL"
}

variable "helm_chart" {
  type        = string
  description = "Helm chart name"
}

variable "chart_version" {
  type        = string
  description = "Helm chart version"
}

variable "image_repo" {
  type        = string
  description = "Container image repository"
}

variable "image_tag" {
  type        = string
  description = "Container image tag"
}

variable "kafka_bootstrap" {
  type        = string
  description = "Kafka bootstrap servers"
}

variable "kinesis_stream" {
  type        = string
  description = "Kinesis stream name"
}

variable "redis_endpoint" {
  type        = string
  description = "Redis endpoint"
}

variable "log_level" {
  type        = string
  default     = "INFO"
}

variable "replicas" {
  type        = number
  default     = 3
}

variable "cpu_request" {
  type        = string
  default     = "250m"
}

variable "memory_request" {
  type        = string
  default     = "512Mi"
}

variable "cpu_limit" {
  type        = string
  default     = "500m"
}

variable "memory_limit" {
  type        = string
  default     = "1Gi"
}

variable "autoscaling_enabled" {
  type        = bool
  default     = true
}

variable "autoscaling_min" {
  type        = number
  default     = 3
}

variable "autoscaling_max" {
  type        = number
  default     = 10
}

variable "autoscaling_cpu_target" {
  type        = number
  default     = 65
}

variable "node_selector" {
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  type        = list(any)
  default     = []
}

variable "affinity" {
  type        = any
  default     = {}
}
