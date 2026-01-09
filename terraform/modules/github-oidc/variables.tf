variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "demo-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "github_repo" {
  description = "GitHub repository in format owner/repo"
  type        = string
  default     = "snirkap/ArtAc-home-assignment-"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
  default     = "064195113262"
}
