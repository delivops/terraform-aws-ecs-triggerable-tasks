output "task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.task_definition.arn
}

output "task_definition_family" {
  description = "Family of the ECS task definition"
  value       = aws_ecs_task_definition.task_definition.family
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs_log_group.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs_log_group.arn
}

output "task_execution_role_arn" {
  description = "ARN of the ECS Task Execution role (if created)"
  value       = var.initial_role != "" ? var.initial_role : try(aws_iam_role.task_execution_role[0].arn, "")
}

output "cluster_arn" {
  description = "ARN of the ECS cluster (for use with aws ecs run-task)"
  value       = data.aws_ecs_cluster.ecs_cluster.arn
}

output "task_details" {
  description = "Details about the triggerable task configuration"
  value = {
    cluster_name              = var.ecs_cluster_name
    cluster_arn               = data.aws_ecs_cluster.ecs_cluster.arn
    task_name                 = var.name
    task_definition_family    = aws_ecs_task_definition.task_definition.family
    launch_type               = length(var.capacity_provider_strategy) == 0 ? var.ecs_launch_type : "capacity_provider"
    capacity_provider_enabled = length(var.capacity_provider_strategy) > 0
    subnet_ids                = var.subnet_ids
    security_group_ids        = var.security_group_ids
    assign_public_ip          = var.assign_public_ip
  }
}

output "capacity_provider_strategy" {
  description = "Capacity provider strategy configuration (empty if using launch_type)"
  value       = var.capacity_provider_strategy
}
