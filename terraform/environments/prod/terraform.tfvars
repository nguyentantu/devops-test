# AWS Configuration
aws_region  = "us-east-1"
environment = "prod"
app_name    = "sample-app"

# Pre-existing VPC Configuration
# Replace with your actual VPC ID
vpc_id = "vpc-0123456789abcdef0"

# Private subnets for ECS tasks (leave empty to auto-discover by tag)
private_subnet_ids = [
  "subnet-0123456789abcdef0",
  "subnet-0123456789abcdef1"
]

# Public subnets (if needed)
public_subnet_ids = [
  "subnet-0123456789abcdef2",
  "subnet-0123456789abcdef3"
]

# Pre-existing Application Load Balancer
# Replace with your actual ALB ARN
alb_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/50dc6c495c0c9188"

# Replace with your actual HTTPS listener ARN
alb_listener_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/my-alb/50dc6c495c0c9188/f2f7dc8efc522ab2"

# Replace with your actual target group ARN
target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-target-group/50dc6c495c0c9188"

# ALB Security Group
# Set to true to create a new security group, or provide existing SG ID
create_alb_security_group = false
alb_security_group_id     = "sg-0123456789abcdef0"

# Pre-existing SSL Certificate
# Replace with your actual ACM certificate ARN
acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"

# IAM Roles (Pre-existing)
ecs_task_execution_role_name = "ecsTaskExecutionRole"
ecs_task_role_name           = "ecsTaskRole"

# Domain Configuration
domain_name = "sample-app.example.com"

# ECR Configuration
ecr_image_tag_mutability  = "MUTABLE"
ecr_scan_on_push          = true
ecr_image_retention_count = 10
ecr_untagged_retention_days = 7

# ECS Configuration
container_port     = 3000
ecs_cpu            = "256"
ecs_memory         = "512"
ecs_desired_count  = 2

# CloudWatch
enable_container_insights = true
log_retention_days        = 7

# Auto-scaling (Optional - set to true to enable)
enable_autoscaling        = false
autoscaling_min_capacity  = 1
autoscaling_max_capacity  = 4
autoscaling_cpu_target    = 70
autoscaling_memory_target = 80

# Monitoring (Optional - provide SNS topic ARN for alerts)
alarm_sns_topic_arn = ""

# Additional Tags
tags = {
  Project    = "DevOps Assessment"
  Owner      = "Tu Nguyen"
  CostCenter = "Engineering"
}
