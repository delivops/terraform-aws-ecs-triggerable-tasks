[![DelivOps banner](https://raw.githubusercontent.com/delivops/.github/main/images/banner.png?raw=true)](https://delivops.com)

# AWS ECS Triggerable Task Terraform Module

This Terraform module deploys ECS task definitions on AWS that can be triggered programmatically from code (Lambda functions, ECS services, Step Functions, or any AWS SDK). Unlike scheduled tasks, there's no EventBridge scheduling — you control when and how tasks run.

## Features

- ✅ Creates ECS task definitions ready for **on-demand triggering**
- ✅ **Fargate Spot support** for cost savings (up to 70% cheaper)
- ✅ **Flexible capacity provider strategies** (Spot, Regular, or Mixed)
- ✅ Network configuration for Fargate and EC2 launch types
- ✅ CloudWatch logging integration
- ✅ Tagging support for all resources
- ✅ Task definition management with ignore changes for external deployments
- ✅ Outputs designed for easy `aws ecs run-task` invocation

## Usage

### Basic Example (Fargate)

```hcl
module "ecs_triggerable_task" {
  source = "delivops/ecs-triggerable-task/aws"
  
  ecs_cluster_name = "my-cluster"
  name             = "data-sync"
  description      = "Syncs data on demand"
}
```

### Triggering the Task

After applying, trigger the task using the AWS CLI:

```bash
aws ecs run-task \
  --cluster my-cluster \
  --task-definition my-cluster_data-sync \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx],assignPublicIp=DISABLED}"
```

Or use module outputs:

```bash
aws ecs run-task \
  --cluster $(terraform output -raw module.ecs_triggerable_task.cluster_arn) \
  --task-definition $(terraform output -raw module.ecs_triggerable_task.task_definition_family) \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx],assignPublicIp=DISABLED}"
```

### Triggering from Lambda (Python)

```python
import boto3

def handler(event, context):
    ecs = boto3.client('ecs')
    response = ecs.run_task(
        cluster='my-cluster',
        taskDefinition='my-cluster_data-sync',
        launchType='FARGATE',
        networkConfiguration={
            'awsvpcConfiguration': {
                'subnets': ['subnet-xxx'],
                'securityGroups': ['sg-xxx'],
                'assignPublicIp': 'DISABLED'
            }
        },
        overrides={
            'containerOverrides': [{
                'name': 'my-container',
                'command': ['python', 'script.py', '--arg', event.get('arg', 'default')]
            }]
        }
    )
    return response
```

### Example with Multiple Tasks in Same Cluster

```hcl
module "data_sync_task" {
  source = "delivops/ecs-triggerable-task/aws"
  
  ecs_cluster_name = "my-cluster"
  name             = "data-sync"
  description      = "Syncs data between sources"
}

module "report_generator_task" {
  source = "delivops/ecs-triggerable-task/aws"
  
  ecs_cluster_name = "my-cluster"
  name             = "report-generator"
  description      = "Generates reports on demand"
}
```


### Example with Fargate Spot (Cost Savings)

```hcl
module "fargate_spot_task" {
  source = "delivops/ecs-triggerable-task/aws"
  
  ecs_cluster_name = "my-cluster"
  name             = "batch-job"
  description      = "Batch job on Spot"
  
  # Use 100% Fargate Spot for maximum cost savings (up to 70% cheaper)
  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
      base              = 0
    }
  ]
}
```

### Example with Mixed Capacity (Spot + Regular Fargate)

```hcl
module "mixed_capacity_task" {
  source = "delivops/ecs-triggerable-task/aws"
  
  ecs_cluster_name = "production"
  name             = "balanced-task"
  description      = "Balanced task with mixed capacity"
  
  # Mixed strategy: 70% Spot (cost savings) + 30% Regular (reliability)
  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 70
      base              = 0
    },
    {
      capacity_provider = "FARGATE"
      weight            = 30
      base              = 0
    }
  ]
}
```

## Fargate Spot vs Regular Fargate

| Feature | Regular Fargate | Fargate Spot | Mixed Strategy |
|---------|----------------|--------------|----------------|
| **Cost** | Standard pricing | Up to 70% cheaper | 30-60% cheaper |
| **Availability** | Guaranteed | Can be interrupted | Balanced |
| **Best For** | Critical, time-sensitive tasks | Fault-tolerant, flexible workloads | Production with cost awareness |
| **Interruption** | Never | 2-minute warning | Partial protection |
| **Recommendation** | Payment processing, user-facing | Data sync, batch jobs, reports | General production workloads |

### When to Use Fargate Spot

**✅ Good use cases:**
- Batch processing jobs
- Data synchronization tasks
- Report generation
- ETL pipelines
- Log processing
- Non-time-critical workloads

**❌ Avoid for:**
- Real-time payment processing
- User-facing critical operations
- Tasks that cannot tolerate 2-minute interruptions
- Stateful workloads without proper checkpointing

## Use Cases

This module is ideal for:

- **Event-driven tasks** - Triggered by application events (user actions, API calls)
- **Lambda-triggered tasks** - Long-running jobs that exceed Lambda's 15-minute limit
- **Step Functions workflows** - Tasks orchestrated as part of larger workflows
- **Manual/on-demand tasks** - Triggered via CLI or console when needed
- **CI/CD pipelines** - Build, test, or deployment tasks
- **Queue processors** - Tasks triggered by SQS messages

## Notes

- The module creates an initial placeholder task definition that will be overridden
- Task definition changes are ignored to support external deployments
- For Fargate tasks, network mode is always "awsvpc"
- CPU, memory, container image, and container name should be managed in your actual task definition, not in this module
- Use the `cluster_arn` and `task_definition_family` outputs for easy run-task invocation

## License

This module is released under the MIT License.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.ecs_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_task_definition.task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.task_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_ecs_cluster.ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description for the triggerable task. If not provided, a default description will be generated. | `string` | `""` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Name of the ECS cluster | `string` | n/a | yes |
| <a name="input_initial_role"></a> [initial\_role](#input\_initial\_role) | ARN of the IAM role to use for both task role and execution role | `string` | `""` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain logs | `number` | `7` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the triggerable task | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of the CloudWatch log group |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of the CloudWatch log group |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN of the ECS cluster (for use with aws ecs run-task) |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | ARN of the ECS task definition |
| <a name="output_task_definition_family"></a> [task\_definition\_family](#output\_task\_definition\_family) | Family of the ECS task definition |
| <a name="output_task_details"></a> [task\_details](#output\_task\_details) | Details about the triggerable task configuration |
| <a name="output_task_execution_role_arn"></a> [task\_execution\_role\_arn](#output\_task\_execution\_role\_arn) | ARN of the ECS Task Execution role (if created) |
<!-- END_TF_DOCS -->
