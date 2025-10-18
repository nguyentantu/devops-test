# DevOps Engineer Technical Assessment - CI/CD Pipeline Solution

## 📋 Overview

This repository contains a complete CI/CD pipeline implementation for deploying a Flask-based application to AWS ECS using Infrastructure as Code (Terraform) and GitHub Actions.

## Solution Approach

### 1. Infrastructure as Code (Terraform)
I chose **Terraform** for the following reasons:
- **Declarative syntax**: Easy to read and maintain
- **State management**: Tracks infrastructure changes reliably
- **Modular design**: Reusable modules for different environments
- **AWS provider maturity**: Comprehensive support for all AWS services
- **Community support**: Extensive documentation and examples

### 2. CI/CD Pipeline (GitHub Actions)
I implemented **GitHub Actions** because:
- **Native GitHub integration**: No additional services needed
- **Free for public repositories**: Cost-effective solution
- **Secrets management**: Secure credential storage
- **Matrix builds**: Support for multi-environment deployments
- **Rich ecosystem**: Thousands of pre-built actions available

### 3. Container Orchestration (Amazon ECS)
I selected **ECS Fargate** over EKS for:
- **Serverless**: No need to manage EC2 instances
- **Simpler setup**: Less operational overhead than Kubernetes
- **Cost-effective**: Pay only for running tasks
- **AWS-native**: Better integration with ALB, IAM, CloudWatch
- **Quick deployment**: Faster setup for this assessment scope

## 📁 Project Structure

```
devops-test/
├── .github/
│   └── workflows/
│       └── deploy.yml                 # CI/CD pipeline definition
├── terraform/
│   ├── modules/
│   │   ├── ecr/                       # ECR repository module
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── ecs/                       # ECS cluster & service module
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   ├── environments/
│   │   └── prod/
│   │       ├── main.tf                # Production environment
│   │       ├── variables.tf
│   │       ├── terraform.tfvars       # Environment-specific values
│   │       └── outputs.tf
│   └── backend.tf                     # Terraform state backend config
├── Dockerfile                         # Application container image
├── main.py                            # Flask application
├── pyproject.toml                     # Python dependencies
└── tests/                             # Unit tests
    └── test_healthcheck.py
```

## 🔧 Implementation Details

### Terraform Modules

#### ECR Module
- Creates Amazon ECR repository for Docker images
- Configures image scanning on push
- Sets lifecycle policy to retain last 10 images
- Enables image tag immutability (optional)

#### ECS Module
- Creates ECS cluster (Fargate launch type)
- Defines task definition with:
  - Container configuration (CPU: 256, Memory: 512)
  - Environment variables
  - Health check configuration
  - CloudWatch logging
- Creates ECS service with:
  - Desired count: 2 (for high availability)
  - Rolling update deployment strategy
  - Integration with existing ALB
  - Target group attachment
  - Auto-scaling configuration (optional)
- Security groups for container traffic

### GitHub Actions Workflow

**Triggers:**
- Push to `main` branch
- Manual workflow dispatch

**Stages:**

1. **Build**
   - Checkout code
   - Set up Docker Buildx
   - Build Docker image
   - Tag with commit SHA and `latest`

2. **Test**
   - Run unit tests using pytest
   - Generate coverage report
   - Fail pipeline if tests don't pass

3. **Deploy**
   - Configure AWS credentials
   - Login to Amazon ECR
   - Push Docker image to ECR
   - Update ECS task definition
   - Deploy new task revision
   - Wait for service stability

## 🔐 Required Secrets (GitHub)

The following secrets need to be configured in GitHub repository settings:

```
AWS_ACCESS_KEY_ID          # AWS IAM user access key
AWS_SECRET_ACCESS_KEY      # AWS IAM user secret key
AWS_REGION                 # AWS region (e.g., us-east-1)
ECR_REPOSITORY_URL         # ECR repository URL
ECS_CLUSTER_NAME           # ECS cluster name
ECS_SERVICE_NAME           # ECS service name
ECS_TASK_DEFINITION        # Task definition family name
```

## 📋 Prerequisites

Before deploying, ensure you have:

1. **AWS Account** with appropriate permissions
2. **Terraform** installed (v1.5+)
3. **AWS CLI** configured with credentials
4. **GitHub repository** with Actions enabled
5. **Pre-existing AWS resources:**
   - VPC with public/private subnets
   - Application Load Balancer
   - ALB Target Group
   - SSL Certificate (ACM)
   - IAM Role for ECS Task Execution
   - Route53 hosted zone (for DNS)

## 🚀 Deployment Steps

### Step 1: Clone Repository
```bash
git clone <repository-url>
cd devops-test
```

### Step 2: Configure Terraform Variables
Edit `terraform/environments/prod/terraform.tfvars`:

```hcl
# AWS Configuration
aws_region = "us-east-1"
environment = "prod"
app_name = "sample-app"

# Networking (pre-existing)
vpc_id = "vpc-xxxxxxxxx"
private_subnet_ids = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"]
public_subnet_ids = ["subnet-aaaaaaaa", "subnet-bbbbbbbb"]

# Load Balancer (pre-existing)
alb_arn = "arn:aws:elasticloadbalancing:us-east-1:xxxx:loadbalancer/app/my-alb/xxxxx"
alb_listener_arn = "arn:aws:elasticloadbalancing:us-east-1:xxxx:listener/app/my-alb/xxxxx"
target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:xxxx:targetgroup/my-tg/xxxxx"

# SSL Certificate (pre-existing)
acm_certificate_arn = "arn:aws:acm:us-east-1:xxxx:certificate/xxxxx"

# IAM Roles (pre-existing)
ecs_task_execution_role_arn = "arn:aws:iam::xxxx:role/ecsTaskExecutionRole"
ecs_task_role_arn = "arn:aws:iam::xxxx:role/ecsTaskRole"

# Domain
domain_name = "sample-app.example.com"

# ECS Configuration
container_port = 3000
desired_count = 2
cpu = "256"
memory = "512"
```

### Step 3: Initialize Terraform
```bash
cd terraform/environments/prod
terraform init
```

### Step 4: Plan Infrastructure
```bash
terraform plan
```

Review the planned changes carefully.

### Step 5: Apply Infrastructure
```bash
terraform apply
```

Type `yes` to confirm.

### Step 6: Configure GitHub Secrets
Go to GitHub repository → Settings → Secrets and variables → Actions

Add the following secrets with values from Terraform outputs:
```bash
# Get outputs from Terraform
terraform output ecr_repository_url
terraform output ecs_cluster_name
terraform output ecs_service_name
terraform output ecs_task_definition_family
```

### Step 7: Trigger Deployment
Push to main branch or manually trigger the workflow:
```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

### Step 8: Verify Deployment
Monitor the GitHub Actions workflow:
- Go to repository → Actions tab
- Watch the pipeline progress
- Check for any errors

Access the application:
```bash
curl https://sample-app.example.com/healthcheck
```

Expected response:
```json
{
  "status": "ok",
  "app_env": "production",
  "timestamp": "2025-10-18T12:00:00.000000"
}
```

## 🔍 Monitoring & Troubleshooting

### View ECS Service Status
```bash
aws ecs describe-services \
  --cluster sample-app-prod-cluster \
  --services sample-app-prod-service \
  --region us-east-1
```

### View Container Logs
```bash
aws logs tail /ecs/sample-app-prod --follow --region us-east-1
```

### Check Target Group Health
```bash
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn> \
  --region us-east-1
```

### Common Issues

**Issue: Tasks fail to start**
- Check CloudWatch logs for error messages
- Verify security groups allow traffic on port 3000
- Ensure IAM roles have correct permissions

**Issue: Health checks failing**
- Verify health check path is `/healthcheck`
- Check health check interval and timeout settings
- Ensure container port matches task definition

**Issue: Cannot access via ALB**
- Verify target group is attached to ALB listener
- Check security group rules on ALB and ECS tasks
- Verify SSL certificate is valid

## 🔄 Rollback Strategy

If deployment fails:

### Via GitHub Actions:
1. Revert the commit that caused the issue
2. Push to main branch
3. New deployment will roll out previous version

### Via AWS Console:
1. Go to ECS → Clusters → Services
2. Click "Update Service"
3. Select previous task definition revision
4. Click "Update"

### Via CLI:
```bash
aws ecs update-service \
  --cluster sample-app-prod-cluster \
  --service sample-app-prod-service \
  --task-definition sample-app-prod:PREVIOUS_REVISION \
  --region us-east-1
```

## 🎯 Best Practices Implemented

1. **Infrastructure as Code**: All infrastructure is versioned and reproducible
2. **Immutable Deployments**: Each deployment creates new containers
3. **Blue-Green Deployment**: Rolling updates with health checks
4. **Secrets Management**: Credentials stored securely in GitHub Secrets
5. **Health Checks**: Application and container-level health monitoring
6. **Logging**: Centralized logging via CloudWatch
7. **Modular Design**: Reusable Terraform modules
8. **Environment Isolation**: Separate configurations per environment
9. **Automated Testing**: Unit tests run before deployment
10. **Zero-Downtime Deployment**: Rolling updates maintain availability

## 📊 Cost Optimization

- **Fargate Spot**: Consider using Fargate Spot for non-production (60% savings)
- **Auto-scaling**: Scale down during off-peak hours
- **Image lifecycle**: Automatically delete old ECR images
- **CloudWatch Logs**: Set retention period (7-30 days)
- **Right-sizing**: Monitor CPU/memory usage and adjust task definition

## 🔐 Security Considerations

1. **IAM Least Privilege**: Task roles have minimal required permissions
2. **Network Isolation**: Tasks run in private subnets
3. **Secrets Management**: Use AWS Secrets Manager for sensitive data
4. **Image Scanning**: ECR scans images for vulnerabilities
5. **HTTPS Only**: All traffic encrypted via SSL/TLS
6. **Security Groups**: Restrict traffic to necessary ports only

## 📚 Additional Resources

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Amazon ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

## 🤝 Contributing

This is a technical assessment project. For production use, consider:
- Multi-region deployment
- Database integration
- Caching layer (Redis/ElastiCache)
- CDN (CloudFront)
- Enhanced monitoring (Datadog, New Relic)
- Disaster recovery plan

## 📝 Notes

- This solution uses **dummy values** for pre-existing resources
- In production, use **Terraform Remote State** (S3 + DynamoDB)
- Consider **AWS CDK** for more complex infrastructure
- Implement **automated rollback** based on CloudWatch alarms
- Use **AWS CodePipeline + CodeBuild** for enterprise setups

---

**Author**: Tu Nguyen  
**Date**: October 18, 2025  
**Purpose**: DevOps Engineer Technical Assessment
