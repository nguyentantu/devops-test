variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, staging, dev)"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "image_retention_count" {
  description = "Number of images to retain"
  type        = number
  default     = 10
}

variable "untagged_image_retention_days" {
  description = "Number of days to retain untagged images"
  type        = number
  default     = 7
}

variable "enable_cross_account_access" {
  description = "Enable cross-account access to ECR repository"
  type        = bool
  default     = false
}

variable "allowed_account_ids" {
  description = "List of AWS account IDs allowed to access the repository"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for the ECR repository"
  type        = map(string)
  default     = {}
}
