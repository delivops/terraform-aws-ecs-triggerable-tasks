################################################################################
# Module Validation Tests
# This file can be used to validate the module works correctly
################################################################################

################################################################################
# Test 1: Minimal Required Configuration
################################################################################

module "test_minimal" {
  source = "../"

  ecs_cluster_name = "test-cluster"
  name             = "test-minimal"
}

################################################################################
# Test 2: All Optional Parameters
################################################################################

module "test_full_config" {
  source = "../"

  # Required parameters
  ecs_cluster_name = "test-cluster"
  name             = "test-full"
  description      = "Full configuration test"

  # Optional parameters
  ecs_launch_type    = "FARGATE"
  initial_role       = ""
  log_retention_days = 14

  tags = {
    Test        = "true"
    Environment = "test"
    Module      = "ecs-triggerable-task"
  }
}

################################################################################
# Test 3: EC2 Launch Type
################################################################################

module "test_ec2_launch" {
  source = "../"

  ecs_cluster_name = "ec2-cluster"
  name             = "test-ec2"

  ecs_launch_type = "EC2"

  # Note: For EC2, network_mode will be "bridge" instead of "awsvpc"
}

################################################################################
# Test 4: Capacity Provider Strategies
################################################################################

module "test_fargate_spot" {
  source = "../"

  ecs_cluster_name = "test-cluster"
  name             = "test-spot"

  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
      base              = 0
    }
  ]
}

module "test_mixed_capacity" {
  source = "../"

  ecs_cluster_name = "test-cluster"
  name             = "test-mixed"

  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 80
      base              = 0
    },
    {
      capacity_provider = "FARGATE"
      weight            = 20
      base              = 0
    }
  ]
}

################################################################################
# Test 5: Custom IAM Roles
################################################################################

resource "aws_iam_role" "test_task_role" {
  name = "test-triggerable-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

module "test_custom_iam" {
  source = "../"

  ecs_cluster_name = "test-cluster"
  name             = "test-custom-iam"

  initial_role = aws_iam_role.test_task_role.arn
}

################################################################################
# Test 6: Log Retention Configurations
################################################################################

module "test_short_retention" {
  source = "../"

  ecs_cluster_name = "test-cluster"
  name             = "test-short-logs"

  log_retention_days = 1
}

module "test_long_retention" {
  source = "../"

  ecs_cluster_name = "test-cluster"
  name             = "test-long-logs"

  log_retention_days = 365
}

################################################################################
# Expected Outputs Validation
################################################################################

output "test_minimal_outputs" {
  value = {
    task_definition_arn       = module.test_minimal.task_definition_arn
    task_definition_family    = module.test_minimal.task_definition_family
    cloudwatch_log_group_name = module.test_minimal.cloudwatch_log_group_name
    cloudwatch_log_group_arn  = module.test_minimal.cloudwatch_log_group_arn
    task_execution_role_arn   = module.test_minimal.task_execution_role_arn
    cluster_arn               = module.test_minimal.cluster_arn
    task_details              = module.test_minimal.task_details
  }

  description = "All outputs from the minimal configuration test"
}

# Validation Rules:
# 1. Each module should create exactly 3-4 resources (depending on IAM role)
# 2. Task definition should be created with lifecycle ignore_changes
# 3. CloudWatch log group should be created for task logs
# 4. IAM role should be created if not provided
# 5. Outputs should include cluster_arn for easy run-task invocation
