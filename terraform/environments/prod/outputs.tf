# ECR Outputs
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr.repository_arn
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs.cluster_arn
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

output "ecs_task_definition_family" {
  description = "Family name of the task definition"
  value       = module.ecs.task_definition_family
}

output "ecs_task_definition_arn" {
  description = "ARN of the task definition"
  value       = module.ecs.task_definition_arn
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = module.ecs.log_group_name
}

# Application URL
output "application_url" {
  description = "URL to access the application"
  value       = "https://${var.domain_name}"
}

# Instructions for GitHub Secrets
output "github_secrets_instructions" {
  description = "Instructions for setting up GitHub Secrets"
  value = <<-EOT
    
    ========================================
    GitHub Secrets Configuration
    ========================================
    
    Add these secrets to your GitHub repository:
    Settings → Secrets and variables → Actions → New repository secret
    
    AWS_ACCESS_KEY_ID:
      Get from AWS IAM user with appropriate permissions
    
    AWS_SECRET_ACCESS_KEY:
      Get from AWS IAM user (secret key)
    
    AWS_REGION:
      ${var.aws_region}
    
    ECR_REPOSITORY_URL:
      ${module.ecr.repository_url}
    
    ECS_CLUSTER_NAME:
      ${module.ecs.cluster_name}
    
    ECS_SERVICE_NAME:
      ${module.ecs.service_name}
    
    ECS_TASK_DEFINITION:
      ${module.ecs.task_definition_family}
    
    ========================================
    Next Steps:
    1. Configure the above secrets in GitHub
    2. Push to main branch to trigger deployment
    3. Access your app at: https://${var.domain_name}/healthcheck
    ========================================
  EOT
}
