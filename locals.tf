locals {
  # Task description
  task_description = var.description != "" ? var.description : "Triggerable task: ${var.name}"

  # Determine if using Fargate (regular or Spot via capacity provider)
  is_fargate = length(var.capacity_provider_strategy) > 0 ? (
    contains([for cp in var.capacity_provider_strategy : cp.capacity_provider], "FARGATE") ||
    contains([for cp in var.capacity_provider_strategy : cp.capacity_provider], "FARGATE_SPOT")
  ) : var.ecs_launch_type == "FARGATE"

  # Determine requires_compatibilities based on launch type or capacity provider
  requires_compatibility = length(var.capacity_provider_strategy) > 0 ? (
    local.is_fargate ? "FARGATE" : "EC2"
  ) : var.ecs_launch_type

  # Task definition family name
  task_family = "${data.aws_ecs_cluster.ecs_cluster.cluster_name}_${var.name}"

  # CloudWatch log group name
  log_group_name = "/ecs/${data.aws_ecs_cluster.ecs_cluster.cluster_name}/${var.name}"

  # Container definition for the initial task
  # This is a placeholder task definition that will be ignored due to lifecycle ignore_changes
  container_definitions_json = jsonencode([
    {
      name      = "placeholder"
      image     = "public.ecr.aws/docker/library/alpine:latest"
      essential = true
      cpu       = 256
      memory    = 512
      command   = ["sh", "-c", "echo 'Placeholder task - update task definition externally' && sleep 60"]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = local.log_group_name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}
