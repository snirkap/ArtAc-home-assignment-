# Demo Java Application - DevOps Assignment

A complete CI/CD pipeline setup for a Java Spring Boot application with Docker containerization and AWS infrastructure provisioning using Terraform.

## Architecture

```
+----------------+     +------------------+     +------------------+
|  GitHub Repo   |---->|  GitHub Actions  |---->|   Docker Hub     |
|                |     |     (CI/CD)      |     |  (Public Repo)   |
+----------------+     +--------+---------+     +--------+---------+
                                |                        |
                                | OIDC                   |
                                v                        |
                       +------------------+              |
                       |  AWS IAM Role    |              |
                       |  (Assume Role)   |              |
                       +--------+---------+              |
                                |                        |
                                | SSM                    | Pull Image
                                v                        v
                       +------------------------------------+
                       |            AWS EC2                 |
                       |  +------------------------------+  |
                       |  |     Docker Container         |  |
                       |  |     (Spring Boot App)        |  |
                       |  |          :8080               |  |
                       |  +------------------------------+  |
                       +------------------------------------+
```

## Project Structure

```
├── .github/
│   └── workflows/
│       └── ci-cd.yml              # GitHub Actions CI/CD pipeline
├── src/
│   ├── main/
│   │   ├── java/com/example/demo/
│   │   │   ├── DemoApplication.java
│   │   │   └── controller/
│   │   │       └── HelloController.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       └── java/com/example/demo/
│           └── DemoApplicationTests.java
├── terraform/
│   ├── modules/
│   │   ├── ec2/                   # EC2 instance module
│   │   │   ├── ec2.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── user_data.sh
│   │   ├── iam/                   # IAM role for EC2 (SSM access)
│   │   │   ├── iam.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── github-oidc/           # GitHub OIDC authentication
│   │       ├── oidc.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   ├── main.tf                    # Root module
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf               # AWS provider + S3 backend
│   └── terraform.tfvars.example
├── gradle/
│   └── wrapper/
├── build.gradle                   # Gradle build configuration
├── settings.gradle
├── Dockerfile                     # Multi-stage Docker build
├── .dockerignore
├── .gitignore
├── gradlew                        # Gradle wrapper (Unix)
└── gradlew.bat                    # Gradle wrapper (Windows)
```

## Prerequisites

- Java 17 or higher
- Docker
- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- GitHub account
- Docker Hub account (with a **public** repository)

## Running Locally

### Build and Run with Gradle

```bash
# Build the application
./gradlew build

# Run tests
./gradlew test

# Run the application
./gradlew bootRun
```

The application will be available at `http://localhost:8080`

### Build and Run with Docker

```bash
# Build the Docker image
docker build -t demo-app .

# Run the container
docker run -p 8080:8080 demo-app
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Welcome message with timestamp |
| `/health` | GET | Health check endpoint |
| `/api/hello` | GET | Hello API endpoint |
| `/actuator/health` | GET | Spring Boot Actuator health |

## CI/CD Pipeline

The GitHub Actions pipeline (`.github/workflows/ci-cd.yml`) performs:

1. **Build and Test** - Compiles the application and runs unit tests
2. **Docker Build and Push** - Builds Docker image and pushes to Docker Hub
3. **Deploy to EC2** - Deploys via AWS SSM (no SSH required)

### Security Features

- **GitHub OIDC**: No static AWS credentials stored - uses short-lived tokens
- **SSM Deployment**: No SSH keys or open ports needed
- **Public Docker Hub**: EC2 pulls images without credentials
- **Tag-based IAM Policy**: SSM commands only work on tagged instances

### Required GitHub Secrets

Configure these secrets in your GitHub repository (Settings → Secrets and variables → Actions):

| Secret | Description |
|--------|-------------|
| `AWS_ROLE_ARN` | IAM role ARN for GitHub OIDC (from Terraform output) |
| `EC2_INSTANCE_ID` | EC2 instance ID (from Terraform output) |
| `EC2_PUBLIC_IP` | EC2 public IP (from Terraform output) |
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token (for pushing images) |

### Pipeline Triggers

- Manual trigger via workflow_dispatch

## Infrastructure Setup with Terraform

### Architecture

Terraform creates the following resources:

| Module | Resources |
|--------|-----------|
| `iam` | IAM role + instance profile for EC2 SSM access |
| `ec2` | EC2 instance (Ubuntu or Amazon Linux), security group, Elastic IP |
| `github-oidc` | IAM role for GitHub Actions OIDC authentication (uses existing OIDC provider) |

**Note:** The user_data script auto-detects the OS and installs Docker accordingly (apt for Ubuntu, dnf for Amazon Linux).

### Initial Setup

1. Navigate to the terraform directory:
   ```bash
   cd terraform
   ```

2. Copy and configure variables:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. Initialize Terraform (with S3 backend):
   ```bash
   terraform init
   ```

4. Review the execution plan:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

### Terraform Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `app_name` | Application name | `demo-app` |
| `environment` | Environment name | `dev` |
| `aws_region` | AWS region | `us-east-1` |
| `docker_image` | Public Docker image to deploy | - |
| `github_repo` | GitHub repo (owner/repo format) | - |

### Terraform Outputs

After `terraform apply`, you'll see:

```
application_url         = "http://<IP>:8080"
github_actions_role_arn = "arn:aws:iam::xxx:role/demo-app-github-actions-role"
instance_id             = "i-xxx"
instance_public_ip      = "x.x.x.x"
ssm_connect_command     = "aws ssm start-session --target i-xxx"
```

### Remote State

Terraform state is stored in S3 for team collaboration:
- Bucket: `artac-home-assignment-remote-state`
- State locking via S3 native locking (`use_lockfile = true`)

### Cleanup

To destroy all created resources:
```bash
terraform destroy
```

## Docker Image Details

The Dockerfile uses a multi-stage build:

1. **Builder Stage**: Uses `eclipse-temurin:17-jdk-alpine` to compile the application
2. **Runtime Stage**: Uses `eclipse-temurin:17-jre-alpine` for a lightweight runtime image

Features:
- Non-root user for security
- Health check configured
- Optimized layer caching
- Minimal image size (~200MB)

## Security Considerations

| Feature | Implementation |
|---------|----------------|
| No SSH | EC2 access via SSM Session Manager only |
| No static AWS keys | GitHub OIDC provides short-lived credentials |
| No credentials on EC2 | Docker Hub repo is public |
| Least privilege | Tag-based IAM policy restricts SSM to specific instances |
| Encrypted storage | EBS volumes are encrypted |
| Non-root container | Docker container runs as unprivileged user |
| Security group | Only port 8080 exposed (no SSH port 22) |

## Troubleshooting

### Connect to EC2 via SSM

```bash
aws ssm start-session --target <instance-id>
```

### Check user data logs

```bash
# After connecting via SSM
sudo cat /var/log/user-data.log
```

### Check Docker container logs

```bash
docker logs demo-app
```

### GitHub Actions failing

1. Verify all required secrets are configured
2. Check the Actions tab for detailed error logs
3. Ensure Docker Hub repository is **public**
4. Verify the IAM role trust policy includes your repo

### Terraform errors

1. Ensure AWS credentials are configured locally
2. If OIDC provider already exists, Terraform uses a data source (not a resource)
3. Check S3 bucket for remote state exists

## Quick Start Checklist

- [ ] Create Docker Hub account and **public** repository
- [ ] Create S3 bucket for Terraform remote state
- [ ] Configure AWS CLI credentials locally
- [ ] Run `terraform apply` in `/terraform`
- [ ] Add GitHub secrets from Terraform outputs:
  - `AWS_ROLE_ARN`
  - `EC2_INSTANCE_ID`
  - `EC2_PUBLIC_IP`
  - `DOCKERHUB_USERNAME`
  - `DOCKERHUB_TOKEN`
- [ ] Push code to GitHub
- [ ] Run the workflow manually from Actions tab
- [ ] Access app at `http://<EC2_IP>:8080`