# AWS Configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "sample-app"
}

# Networking - Pre-existing Resources
variable "vpc_id" {
  description = "ID of existing VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs (leave empty to auto-discover)"
  type        = list(string)
  default     = []
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
  default     = []
}

# Load Balancer - Pre-existing Resources
variable "alb_arn" {
  description = "ARN of existing Application Load Balancer"
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN of ALB HTTPS listener"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of ALB target group"
  type        = string
}

variable "create_alb_security_group" {
  description = "Create a new security group for ALB (set to false if using existing)"
  type        = bool
  default     = false
}

variable "alb_security_group_id" {
  description = "Security group ID of existing ALB (required if create_alb_security_group is false)"
  type        = string
  default     = ""
}

# SSL Certificate - Pre-existing Resource
variable "acm_certificate_arn" {
  description = "ARN of ACM certificate for HTTPS"
  type        = string
}

# IAM Roles - Pre-existing Resources
variable "ecs_task_execution_role_name" {
  description = "Name of existing ECS task execution role"
  type        = string
  default     = "ecsTaskExecutionRole"
}

variable "ecs_task_role_name" {
  description = "Name of existing ECS task role"
  type        = string
  default     = "ecsTaskRole"
}

# Domain Configuration
variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "sample-app.example.com"
}

# ECR Configuration
variable "ecr_image_tag_mutability" {
  description = "Image tag mutability (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "ecr_image_retention_count" {
  description = "Number of images to retain"
  type        = number
  default     = 10
}

variable "ecr_untagged_retention_days" {
  description = "Days to retain untagged images"
  type        = number
  default     = 7
}

variable "ecr_enable_cross_account" {
  description = "Enable cross-account access"
  type        = bool
  default     = false
}

variable "ecr_allowed_account_ids" {
  description = "AWS account IDs for cross-account access"
  type        = list(string)
  default     = []
}

# ECS Configuration
variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 3000
}

variable "ecs_cpu" {
  description = "CPU units for ECS task"
  type        = string
  default     = "256"
}

variable "ecs_memory" {
  description = "Memory for ECS task (MB)"
  type        = string
  default     = "512"
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention days"
  type        = number
  default     = 7
}

# Auto-scaling Configuration
variable "enable_autoscaling" {
  description = "Enable ECS service auto-scaling"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum task count for auto-scaling"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum task count for auto-scaling"
  type        = number
  default     = 4
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization for auto-scaling"
  type        = number
  default     = 70
}

variable "autoscaling_memory_target" {
  description = "Target memory utilization for auto-scaling"
  type        = number
  default     = 80
}

# Monitoring
variable "alarm_sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarms"
  type        = string
  default     = ""
}

# Tags
variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
