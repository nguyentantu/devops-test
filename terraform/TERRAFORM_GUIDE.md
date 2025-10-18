# Terraform Quick Start Guide

## Prerequisites
- Terraform >= 1.5.0
- AWS CLI configured with credentials
- Appropriate AWS permissions

## Initial Setup

### 1. Navigate to the production environment
```bash
cd terraform/environments/prod
```

### 2. Create your terraform.tfvars file
```bash
cp terraform.tfvars.example terraform.tfvars
```

### 3. Edit terraform.tfvars with your actual AWS resources
```bash
# Use your favorite editor
vim terraform.tfvars
# or
code terraform.tfvars
```

Update these values:
- `vpc_id`: Your VPC ID
- `private_subnet_ids`: Your private subnet IDs
- `alb_arn`: Your Application Load Balancer ARN
- `alb_listener_arn`: Your HTTPS listener ARN
- `target_group_arn`: Your target group ARN
- `alb_security_group_id`: Your ALB security group ID
- `acm_certificate_arn`: Your SSL certificate ARN

### 4. Initialize Terraform
```bash
terraform init
```

### 5. Validate configuration
```bash
terraform validate
```

### 6. Plan infrastructure changes
```bash
terraform plan
```

Review the output carefully!

### 7. Apply infrastructure
```bash
terraform apply
```

Type `yes` when prompted.

### 8. Get outputs
```bash
terraform output
```

Copy the output values - you'll need them for GitHub Secrets.

## Updating Infrastructure

### Update task definition or service configuration
1. Edit `variables.tf` or `terraform.tfvars`
2. Run `terraform plan` to preview changes
3. Run `terraform apply` to apply changes

### Update ECS task count
```bash
terraform apply -var="ecs_desired_count=4"
```

## Destroying Infrastructure

**WARNING**: This will delete all resources!

```bash
terraform destroy
```

## Troubleshooting

### State Lock
If you get a state lock error:
```bash
# Force unlock (use with caution!)
terraform force-unlock <LOCK_ID>
```

### Refresh State
```bash
terraform refresh
```

### Import Existing Resources
```bash
# Example: Import an existing ECR repository
terraform import module.ecr.aws_ecr_repository.app sample-app-prod
```

## Best Practices

1. **Always run `terraform plan` before `apply`**
2. **Use remote state in production** (S3 + DynamoDB)
3. **Enable state locking** to prevent concurrent modifications
4. **Version control your .tfvars files** (without sensitive data)
5. **Use workspaces** for multiple environments
6. **Tag all resources** for cost tracking