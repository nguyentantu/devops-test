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

## Remote State Setup (Recommended for Production)

### Create S3 bucket and DynamoDB table
```bash
# Create S3 bucket
aws s3api create-bucket \
  --bucket my-terraform-state-bucket \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket my-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

### Update backend configuration in main.tf
Uncomment the backend block and update with your bucket name:
```hcl
backend "s3" {
  bucket         = "my-terraform-state-bucket"
  key            = "sample-app/prod/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

### Re-initialize with new backend
```bash
terraform init -migrate-state
```

## Useful Commands

```bash
# Show current state
terraform show

# List all resources
terraform state list

# Show specific resource
terraform state show module.ecs.aws_ecs_service.app

# Format code
terraform fmt -recursive

# Generate dependency graph
terraform graph | dot -Tpng > graph.png

# Output specific value
terraform output ecr_repository_url

# Output all in JSON
terraform output -json
```
