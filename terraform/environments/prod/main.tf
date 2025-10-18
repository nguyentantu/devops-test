# Production Environment Terraform Configuration

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration for remote state
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "sample-app/prod/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.app_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "devops-test"
    }
  }
}

# Data sources for existing resources
data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_lb" "main" {
  arn = var.alb_arn
}

data "aws_lb_listener" "https" {
  arn = var.alb_listener_arn
}

data "aws_lb_target_group" "app" {
  arn = var.target_group_arn
}

data "aws_iam_role" "ecs_task_execution" {
  name = var.ecs_task_execution_role_name
}

data "aws_iam_role" "ecs_task" {
  name = var.ecs_task_role_name
}

# Note: ACM certificate ARN is passed directly via variable
# No need to create a data source for it

# Security group for ALB (if not provided)
resource "aws_security_group" "alb" {
  count       = var.create_alb_security_group ? 1 : 0
  name        = "${var.app_name}-${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-alb-sg"
  }
}

# ECR Module
module "ecr" {
  source = "../../modules/ecr"

  app_name                       = var.app_name
  environment                    = var.environment
  image_tag_mutability           = var.ecr_image_tag_mutability
  scan_on_push                   = var.ecr_scan_on_push
  image_retention_count          = var.ecr_image_retention_count
  untagged_image_retention_days  = var.ecr_untagged_retention_days
  enable_cross_account_access    = var.ecr_enable_cross_account
  allowed_account_ids            = var.ecr_allowed_account_ids

  tags = var.tags
}

# ECS Module
module "ecs" {
  source = "../../modules/ecs"

  app_name                    = var.app_name
  environment                 = var.environment
  aws_region                  = var.aws_region
  vpc_id                      = var.vpc_id
  private_subnet_ids          = var.private_subnet_ids != [] ? var.private_subnet_ids : data.aws_subnets.private.ids
  ecr_repository_url          = module.ecr.repository_url
  container_port              = var.container_port
  cpu                         = var.ecs_cpu
  memory                      = var.ecs_memory
  desired_count               = var.ecs_desired_count
  ecs_task_execution_role_arn = data.aws_iam_role.ecs_task_execution.arn
  ecs_task_role_arn           = data.aws_iam_role.ecs_task.arn
  target_group_arn            = var.target_group_arn
  alb_security_group_id       = var.create_alb_security_group ? aws_security_group.alb[0].id : var.alb_security_group_id
  enable_container_insights   = var.enable_container_insights
  log_retention_days          = var.log_retention_days
  enable_autoscaling          = var.enable_autoscaling
  autoscaling_min_capacity    = var.autoscaling_min_capacity
  autoscaling_max_capacity    = var.autoscaling_max_capacity
  autoscaling_cpu_target      = var.autoscaling_cpu_target
  autoscaling_memory_target   = var.autoscaling_memory_target

  tags = var.tags

  depends_on = [module.ecr]
}

# CloudWatch Alarms for monitoring
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.app_name}-${var.environment}-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS CPU utilization"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    ClusterName = module.ecs.cluster_name
    ServiceName = module.ecs.service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${var.app_name}-${var.environment}-memory-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS memory utilization"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    ClusterName = module.ecs.cluster_name
    ServiceName = module.ecs.service_name
  }
}
