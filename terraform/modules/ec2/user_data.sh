#!/bin/bash
set -e

# Log all output
exec > >(tee /var/log/user-data.log) 2>&1
echo "Starting user data script at $(date)"

# Detect OS and install Docker accordingly
if command -v apt-get &> /dev/null; then
    echo "Detected Ubuntu/Debian - using apt"

    # Update packages
    apt-get update -y

    # Install Docker
    apt-get install -y docker.io

    # Start Docker
    systemctl start docker
    systemctl enable docker

    # Add ubuntu user to docker group
    usermod -aG docker ubuntu

elif command -v dnf &> /dev/null; then
    echo "Detected Amazon Linux/RHEL - using dnf"

    # Update packages
    dnf update -y

    # Install Docker
    dnf install -y docker

    # Start Docker
    systemctl start docker
    systemctl enable docker

    # Add ec2-user to docker group
    usermod -aG docker ec2-user
else
    echo "ERROR: Unsupported OS"
    exit 1
fi

echo "Docker installed successfully"
docker --version

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
