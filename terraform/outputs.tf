output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2.instance_public_ip
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${module.ec2.instance_public_ip}:8080"
}

output "ssm_connect_command" {
  description = "AWS CLI command to connect via SSM Session Manager"
  value       = "aws ssm start-session --target ${module.ec2.instance_id}"
}

output "iam_role_name" {
  description = "Name of the IAM role for SSM"
  value       = module.iam.role_name
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.ec2.security_group_id
}

# GitHub OIDC outputs
output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions (use this in your workflow)"
  value       = module.github_oidc.role_arn
}
