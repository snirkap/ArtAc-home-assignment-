resource "aws_security_group" "app_sg" {
  name        = "${var.app_name}-sg"
  description = "Security group for ${var.app_name} application"
  vpc_id      = var.vpc_id

  # Application port only - no SSH needed with SSM
  ingress {
    description = "Application Port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.app_port_cidr_blocks
  }

  # Outbound traffic (required for SSM agent to communicate)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "app_server" {
  ami                         = var.instance_ami_id
  instance_type               = var.instance_type
  iam_instance_profile        = var.iam_instance_profile_name
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    docker_image = var.docker_image
    app_name     = var.app_name
  }))

  tags = {
    Name        = "${var.app_name}-server"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP for consistent public IP
resource "aws_eip" "app_eip" {
  instance = aws_instance.app_server.id
  domain   = "vpc"

  tags = {
    Name        = "${var.app_name}-eip"
    Environment = var.environment
  }
}
