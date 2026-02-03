variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = "my-ecs-cluster"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}
