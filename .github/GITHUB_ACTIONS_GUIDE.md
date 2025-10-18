# GitHub Actions Workflow Guide

## Overview
This CI/CD pipeline automatically builds, tests, and deploys the application to AWS ECS when code is pushed to the main branch.

## Pipeline Stages

### 1. Build Stage
- Checks out code
- Sets up Docker Buildx
- Builds Docker image
- Caches layers for faster builds
- Uploads image as artifact

### 2. Test Stage
- Sets up Python environment
- Installs dependencies with Poetry
- Runs unit tests with pytest
- Generates coverage reports
- Uploads coverage to Codecov

### 3. Deploy Stage (main branch only)
- Downloads built image
- Configures AWS credentials
- Logs in to Amazon ECR
- Pushes image to ECR with tags (SHA + latest)
- Updates ECS task definition
- Deploys to ECS service
- Waits for service stability

## Required GitHub Secrets

Navigate to: \`Repository → Settings → Secrets and variables → Actions\`

Add these secrets:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION
- ECR_REPOSITORY_URL
- ECS_CLUSTER_NAME
- ECS_SERVICE_NAME
- ECS_TASK_DEFINITION

| Secret Name | Description | Example |
|------------|-------------|---------|
| \`AWS_ACCESS_KEY_ID\` | AWS IAM access key | \`AKIAIOSFODNN7EXAMPLE\` |
| \`AWS_SECRET_ACCESS_KEY\` | AWS IAM secret key | \`wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY\` |
| \`AWS_REGION\` | AWS region | \`us-east-1\` |
| \`ECR_REPOSITORY_URL\` | Full ECR repository URL | \`123456789012.dkr.ecr.us-east-1.amazonaws.com/sample-app-prod\` |
| \`ECS_CLUSTER_NAME\` | ECS cluster name | \`sample-app-prod-cluster\` |
| \`ECS_SERVICE_NAME\` | ECS service name | \`sample-app-prod-service\` |
| \`ECS_TASK_DEFINITION\` | Task definition family | \`sample-app-prod\` |

## Getting Secret Values

After running Terraform, get the values:

```bash
cd terraform/environments/prod
terraform output
```

Or get them from AWS CLI:

```bash
# ECR Repository URL
aws ecr describe-repositories \\
  --repository-names sample-app-prod \\
  --query 'repositories[0].repositoryUri' \\
  --output text

# ECS Cluster Name
aws ecs list-clusters \\
  --query 'clusterArns[?contains(@, \`sample-app-prod\`)]' \\
  --output text

# ECS Service Name
aws ecs list-services \\
  --cluster sample-app-prod-cluster \\
  --query 'serviceArns[0]' \\
  --output text
```

## Triggering the Pipeline

### Automatic Trigger
```bash
git add .
git commit -m "Deploy new feature"
git push origin main
```

### Manual Trigger
1. Go to \`Actions\` tab in GitHub
2. Select "CI/CD Pipeline - Build, Test, and Deploy to AWS ECS"
3. Click "Run workflow"
4. Select branch
5. Click "Run workflow"

## Monitoring Pipeline

### View Workflow Run
1. Go to \`Actions\` tab
2. Click on the workflow run
3. Expand each job to see logs

### Check Deployment Status
```bash
# Service status
aws ecs describe-services \\
  --cluster sample-app-prod-cluster \\
  --services sample-app-prod-service \\
  --query 'services[0].{Status:status,Running:runningCount,Desired:desiredCount}'
```

## Rollback

### Option 1: Via GitHub Actions (Manual Trigger)
1. Go to \`Actions\` tab
2. Select the workflow
3. Click "Run workflow"
4. This triggers the rollback job

### Option 2: Via AWS Console
1. Go to ECS → Clusters → Services
2. Click "Update Service"
3. Select previous task definition revision
4. Click "Update"

### Option 3: Via AWS CLI
```bash
# List task definition revisions
aws ecs list-task-definitions \\
  --family-prefix sample-app-prod \\
  --sort DESC

# Update to previous revision
aws ecs update-service \\
  --cluster sample-app-prod-cluster \\
  --service sample-app-prod-service \\
  --task-definition sample-app-prod:PREVIOUS_REVISION
```

### Option 4: Git Revert
```bash
# Revert the problematic commit
git revert HEAD
git push origin main
```

This triggers a new deployment with the previous code.

## Workflow Customization

### Change Python Version
Edit \`.github/workflows/deploy.yml\`:
```yaml
- name: Set up Python
  uses: actions/setup-python@v5
  with:
    python-version: '3.11'  # Change version here
```

### Add Environment Variables
Edit \`.github/workflows/deploy.yml\`:
```yaml
env:
  CUSTOM_VAR: value
  NODE_ENV: production
```

### Add Deployment Notifications
Add Slack notification step:
```yaml
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: \${{ job.status }}
    webhook_url: \${{ secrets.SLACK_WEBHOOK }}
```

### Add Pre-deployment Checks
```yaml
- name: Run integration tests
  run: |
    poetry run pytest tests/integration -v
```

## Troubleshooting

### Build Fails
- Check Dockerfile syntax
- Verify dependencies in pyproject.toml
- Check Python version compatibility

### Tests Fail
- Review test logs in Actions tab
- Run tests locally: \`poetry run pytest -v\`
- Check for environment-specific issues

### ECR Push Fails
- Verify AWS credentials are correct
- Check ECR repository exists
- Ensure IAM user has ECR permissions:
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    }]
  }
  ```

### ECS Deployment Fails
- Check task definition is valid
- Verify security groups allow traffic
- Check CloudWatch logs for errors
- Ensure IAM roles have correct permissions

### Service Won't Stabilize
- Check health check configuration
- Verify container port matches target group
- Review ECS event logs
- Check ALB target health

## Best Practices

1. **Always run tests before deploying**
2. **Use semantic versioning for tags**
3. **Monitor deployment in CloudWatch**
4. **Set up rollback procedures**
5. **Use blue-green deployments for zero downtime**
6. **Enable deployment circuit breaker**
7. **Set up CloudWatch alarms**
8. **Review logs after each deployment**

## Pipeline Optimization

### Speed up builds
```yaml
- name: Build Docker image
  uses: docker/build-push-action@v5
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

### Parallel jobs
```yaml
jobs:
  test-unit:
    runs-on: ubuntu-latest
  test-integration:
    runs-on: ubuntu-latest
    needs: build
  test-e2e:
    runs-on: ubuntu-latest
    needs: build
```

### Conditional deployments
```yaml
deploy:
  if: |
    github.ref == 'refs/heads/main' &&
    !contains(github.event.head_commit.message, '[skip ci]')
```

## Security

1. **Never commit secrets** - Use GitHub Secrets
2. **Use OIDC instead of IAM keys** (recommended)
3. **Rotate AWS credentials regularly**
4. **Scan images for vulnerabilities**
5. **Use least privilege IAM policies**
6. **Enable audit logging**
