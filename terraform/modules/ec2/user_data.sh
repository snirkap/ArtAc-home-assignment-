#!/bin/bash
set -e

# Log all output
exec > >(tee /var/log/user-data.log) 2>&1
echo "Starting user data script at $(date)"

# Update system packages
echo "Updating system packages..."
dnf update -y

# Install Docker
echo "Installing Docker..."
dnf install -y docker

# Start and enable Docker service
echo "Starting Docker service..."
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Pull the application image (public repo - no login needed)
echo "Pulling Docker image: ${docker_image}..."
docker pull ${docker_image}

# Stop and remove existing container if running
echo "Cleaning up existing containers..."
docker stop ${app_name} 2>/dev/null || true
docker rm ${app_name} 2>/dev/null || true

# Run the container
echo "Starting application container..."
docker run -d \
  --name ${app_name} \
  --restart unless-stopped \
  -p 8080:8080 \
  ${docker_image}

# Wait for application to be healthy
echo "Waiting for application to start..."
sleep 15

# Verify application is running
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
  echo "Application is healthy and running!"
else
  echo "Warning: Health check failed, but container may still be starting..."
fi

echo "User data script completed at $(date)"
