variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "name" {
  description = "Name of the triggerable task"
  type        = string
}

variable "description" {
  description = "Description for the triggerable task. If not provided, a default description will be generated."
  type        = string
  default     = ""
}

variable "initial_role" {
  description = "ARN of the IAM role to use for both task role and execution role"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 7
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "log_retention_days must be one of the valid CloudWatch retention periods."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
