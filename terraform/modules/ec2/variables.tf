variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "demo-app"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "app_port_cidr_blocks" {
  description = "CIDR blocks allowed for app port access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_ami_id" {
  description = "EC2 AMI ID (Amazon Linux 2023 recommended for SSM)"
  type        = string
  default     = "ami-0ecb62995f68bb549"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
  default     = "vpc-043038dbef4c9a40e"
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
  default     = "subnet-0c0de02b38cc8144d"
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for SSM access"
  type        = string
}

variable "docker_image" {
  description = "Docker image to deploy (format: username/image:tag)"
  type        = string
  default     = "snirkapah1/demo-app"
}
