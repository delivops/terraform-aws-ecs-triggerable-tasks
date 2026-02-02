################################################################################
# Basic Triggerable Task Example
# This example shows simple triggerable tasks that can be invoked via
# aws ecs run-task, Lambda, Step Functions, or any AWS SDK
################################################################################

module "data_sync_task" {
  source = "../"

  ecs_cluster_name = var.cluster_name
  name             = "data-sync"
  description      = "Data synchronization task"

  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids

  # Use default launch type (FARGATE)
  # Task definition will be managed externally

  tags = {
    Environment = "production"
    Purpose     = "data-sync"
  }
}

################################################################################
# Batch Processing Task
################################################################################

module "batch_processor" {
  source = "../"

  ecs_cluster_name = var.cluster_name
  name             = "batch-processor"
  description      = "Batch data processing task"

  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids

  log_retention_days = 14

  tags = {
    Environment = "production"
    Team        = "data"
  }
}

################################################################################
# ETL Pipeline Task
################################################################################

module "etl_task" {
  source = "../"

  ecs_cluster_name = var.cluster_name
  name             = "etl-pipeline"
  description      = "ETL pipeline for data transformation"

  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids

  tags = {
    Environment = "production"
    Pipeline    = "etl"
  }
}

################################################################################
# Health Check Task
################################################################################

module "health_check_task" {
  source = "../"

  ecs_cluster_name = var.cluster_name
  name             = "health-check"
  description      = "Health check task for external services"

  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids

  assign_public_ip = true # Needs internet access

  tags = {
    Environment = "production"
    Type        = "monitoring"
  }
}

################################################################################
# Example: How to trigger tasks
################################################################################

# After applying, you can trigger any task using the AWS CLI:
#
# aws ecs run-task \
#   --cluster <cluster_name> \
#   --task-definition <task_definition_family> \
#   --launch-type FARGATE \
#   --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx],assignPublicIp=DISABLED}"
#
# Or use the module outputs:
#
# aws ecs run-task \
#   --cluster $(terraform output -raw module.data_sync_task.cluster_arn) \
#   --task-definition $(terraform output -raw module.data_sync_task.task_definition_family)

# Expected resources created:
# - 1 ECS Task Definition per module
# - 1 EventBridge Schedule per module
# - 1 CloudWatch Log Group per module
# - 1 IAM Role + Policy (shared, if not provided)
