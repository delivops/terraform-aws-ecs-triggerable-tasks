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

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the ECS tasks"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the ECS tasks"
  type        = list(string)
}

variable "ecs_launch_type" {
  description = "Launch type for the ECS task (FARGATE or EC2). Ignored if capacity_provider_strategy is set."
  type        = string
  default     = "FARGATE"
  validation {
    condition     = contains(["FARGATE", "EC2"], var.ecs_launch_type)
    error_message = "Valid values for ecs_launch_type are FARGATE or EC2."
  }
}

variable "capacity_provider_strategy" {
  description = "Capacity provider strategy for the ECS task. Use this for Fargate Spot. If set, overrides ecs_launch_type. Example: [{ capacity_provider = \"FARGATE_SPOT\", weight = 1, base = 0 }]"
  type = list(object({
    capacity_provider = string
    weight            = optional(number)
    base              = optional(number)
  }))
  default = []
  validation {
    condition = alltrue([
      for strategy in var.capacity_provider_strategy :
      contains(["FARGATE", "FARGATE_SPOT", "EC2"], strategy.capacity_provider) ||
      can(regex("^[a-zA-Z0-9_-]+$", strategy.capacity_provider))
    ])
    error_message = "capacity_provider must be FARGATE, FARGATE_SPOT, or a valid custom capacity provider name."
  }
}

variable "assign_public_ip" {
  description = "Assign public IP to ECS tasks (Fargate only)"
  type        = bool
  default     = false
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

variable "platform_version" {
  description = "Platform version for Fargate tasks"
  type        = string
  default     = "LATEST"
}

variable "propagate_tags" {
  description = "Propagate tags from the task definition or the service to the tasks"
  type        = string
  default     = "TASK_DEFINITION"
  validation {
    condition     = contains(["TASK_DEFINITION", "NONE"], var.propagate_tags)
    error_message = "propagate_tags must be either TASK_DEFINITION or NONE."
  }
}

variable "placement_constraints" {
  description = "Placement constraints for EC2 launch type"
  type = list(object({
    type       = string
    expression = string
  }))
  default = []
}

variable "enable_ecs_managed_tags" {
  description = "Enable ECS managed tags for the tasks"
  type        = bool
  default     = true
}

variable "group" {
  description = "Group name for the triggerable tasks"
  type        = string
  default     = ""
}
