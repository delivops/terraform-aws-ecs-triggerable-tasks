################################################################################
# Advanced Examples - Custom IAM Role
################################################################################

# Create custom IAM role with specific permissions
resource "aws_iam_role" "custom_task_role" {
  name = "triggerable-task-custom-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to the custom role
resource "aws_iam_role_policy_attachment" "task_execution_policy" {
  role       = aws_iam_role.custom_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "custom_permissions" {
  name = "custom-task-permissions"
  role = aws_iam_role.custom_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::my-data-bucket/*",
          "arn:aws:s3:::my-data-bucket"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:prod/*"
      }
    ]
  })
}

################################################################################
# Triggerable Task with Custom IAM Role
################################################################################

module "secure_task" {
  source = "../"

  ecs_cluster_name = var.cluster_name
  name             = "secure-data-processor"
  description      = "Secure data processor with custom permissions"

  # Use the custom IAM role
  initial_role = aws_iam_role.custom_task_role.arn

  log_retention_days = 30

  tags = {
    Environment = "production"
    Security    = "high"
  }
}

################################################################################
# Multiple Tasks with for_each
################################################################################

locals {
  triggerable_tasks = {
    data_sync = {
      description = "Syncs data between sources"
    }
    report_generator = {
      description = "Generates reports on demand"
    }
    cleanup = {
      description = "Cleanup task for maintenance"
    }
  }
}

module "multiple_tasks" {
  for_each = local.triggerable_tasks
  source   = "../"

  ecs_cluster_name = var.cluster_name
  name             = each.key
  description      = each.value.description

  tags = {
    Environment = "production"
    TaskType    = each.key
  }
}

################################################################################
# Example: Triggering from Lambda
################################################################################

# Example Lambda function code (Python) to trigger an ECS task:
#
# import boto3
#
# def handler(event, context):
#     ecs = boto3.client('ecs')
#     response = ecs.run_task(
#         cluster='my-cluster',
#         taskDefinition='my-cluster_data-sync',
#         launchType='FARGATE',
#         networkConfiguration={
#             'awsvpcConfiguration': {
#                 'subnets': ['subnet-xxx'],
#                 'securityGroups': ['sg-xxx'],
#                 'assignPublicIp': 'DISABLED'
#             }
#         },
#         overrides={
#             'containerOverrides': [{
#                 'name': 'my-container',
#                 'command': ['python', 'script.py', '--arg', event.get('arg', 'default')]
#             }]
#         }
#     )
#     return response

# Expected resources per module:
# - 1 ECS Task Definition
# - 1 CloudWatch Log Group
# - 1 IAM Role + Policy (unless custom role provided)
