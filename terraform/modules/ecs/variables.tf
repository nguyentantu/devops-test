variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, staging, dev)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 3000
}

variable "cpu" {
  description = "CPU units for the task (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memory for the task in MB (512, 1024, 2048, 4096, 8192)"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 2
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group for the load balancer"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID of the Application Load Balancer"
  type        = string
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "enable_autoscaling" {
  description = "Enable auto-scaling for the ECS service"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks when autoscaling"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks when autoscaling"
  type        = number
  default     = 4
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization percentage for autoscaling"
  type        = number
  default     = 70
}

variable "autoscaling_memory_target" {
  description = "Target memory utilization percentage for autoscaling"
  type        = number
  default     = 80
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
