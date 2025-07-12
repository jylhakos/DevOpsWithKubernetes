# Spring Boot JWT authentication with role-based access control

This project implements JWT (JSON Web Token) authentication with role-based access control using Spring Boot, Spring Security, and MySQL.

## Features

- JWT token generation and validation
- Role-based access control (USER and ADMIN roles)
- Password encryption using BCrypt
- Stateless authentication
- RESTful API endpoints
- Method-level security annotations

## Project

```
src/main/java/com/example/server/
├── ServerApplication.java          # Main application class
├── User.java                      # User entity with UserDetails implementation
├── UserRepository.java            # JPA repository for User
├── UserService.java              # UserDetailsService implementation
├── UserController.java           # REST controller for user operations
├── JwtService.java               # JWT utility class
├── JwtAuthenticationFilter.java  # JWT request filter
├── SecurityConfig.java           # Spring Security configuration
├── AuthController.java           # Authentication controller
├── AuthRequest.java              # Login request DTO
├── AuthResponse.java             # Login response DTO
├── CreateUserRequest.java        # Create user request DTO
├── UpdateUserRequest.java        # Update user request DTO
├── TestController.java           # Test endpoints for role verification
├── DataInitializer.java          # Test data initialization
├── ErrorResponse.java            # Error response DTO
└── ResourceNotFoundException.java # Custom exception
```

## API endpoints

### Authentication endpoints
- `POST /api/auth/login` - User login (returns JWT token)

### User endpoints
- `GET /api/user/profile` - Get current user profile (USER, ADMIN)
- `PUT /api/user/profile` - Update current user profile (USER, ADMIN)
- `GET /api/user/data` - Get user data (USER, ADMIN)

### Admin endpoints
- `GET /api/admin/users` - Get all users (ADMIN only)
- `GET /api/admin/users/{id}` - Get user by ID (ADMIN only)
- `POST /api/admin/users` - Create new user (ADMIN only)
- `PUT /api/admin/users/{id}` - Update user by ID (ADMIN only)
- `DELETE /api/admin/users/{id}` - Delete user (ADMIN only)
- `GET /api/admin/dashboard` - Admin dashboard (ADMIN only)

## Default test users

The application creates two test users on startup:

1. **Admin User**
   - Email: `admin@example.com`
   - Password: `admin123`
   - Role: `ADMIN`

2. **Regular User**
   - Email: `user@example.com`
   - Password: `user123`
   - Role: `USER`

## Usage

### 1. Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "admin123"
  }'
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "email": "admin@example.com",
  "role": "ADMIN"
}
```

### 2. Access to protected endpoint
```bash
curl -X GET http://localhost:8080/api/user/profile \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..."
```

### 3. Create new user (Admin only)
```bash
curl -X POST http://localhost:8080/api/admin/users \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New user",
    "email": "newuser@example.com",
    "password": "password123",
    "role": "USER"
  }'
```

### 4. Get all users (Admin only)
```bash
curl -X GET http://localhost:8080/api/admin/users \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..."
```

## Configuration

### JWT configuration (application.properties)
```properties
# JWT secret key (base64 encoded)
jwt.secret=404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
# JWT expiration time (24 hours in milliseconds)
jwt.expiration=86400000
```

### Database configuration
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/springboot_db
spring.datasource.username=root
spring.datasource.password=password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

## Security

### JWT token structure
- **Header**: Algorithm and token type
- **Payload**: User email, issued time, expiration time, and custom claims
- **Signature**: HMAC SHA256 signature

### Role-Based access control
- **Public**: `/api/auth/**` - No authentication required
- **USER**: `/api/user/**` - Requires USER or ADMIN role
- **ADMIN**: `/api/admin/**` - Requires ADMIN role only

### Security Filter Chain
1. JWT Authentication Filter - Extracts and validates JWT tokens
2. Authentication Provider - Validates user credentials
3. Method Security - Enforces role-based access at method level

## Running the application

1. Check MySQL is running on localhost:3306
2. Create database: `CREATE DATABASE springboot_db;`
3. Update database credentials in `application.properties`
4. Run the application: `./gradlew bootRun`
5. Application will start on http://localhost:8080

## Testing Role-Based access

### Test as user
1. Login with `user@example.com` / `user123`
2. Access `/api/user/profile` ✅ (should work)
3. Access `/api/admin/users` ❌ (should return 403 Forbidden)

### Test as admin
1. Login with `admin@example.com` / `admin123`
2. Access `/api/user/profile` ✅ (should work)
3. Access `/api/admin/users` ✅ (should work)

## Error handling

The application includes proper error handling for:
- Invalid credentials (401 Unauthorized)
- Insufficient permissions (403 Forbidden)
- Resource not found (404 Not Found)
- Invalid JWT tokens (401 Unauthorized)
- Expired JWT tokens (401 Unauthorized)

## Dependencies

Key dependencies in `build.gradle`:
- `spring-boot-starter-web`
- `spring-boot-starter-security`
- `spring-boot-starter-data-jpa`
- `spring-boot-starter-validation`
- `jjwt-api`, `jjwt-impl`, `jjwt-jackson` (JWT library)
- `mysql-connector-j` (MySQL driver)

## Dockerizing a Spring Boot application with JWT-secured, role-based access control for deployment on Amazon EKS

### Prerequisites

Before deploying to AWS, ensure you have the following tools installed on your Linux computer:

1. **AWS CLI v2**
2. **kubectl** (Kubernetes command-line tool)
3. **eksctl** (EKS command-line tool)
4. **Terraform** (Infrastructure as Code)
5. **Docker**
6. **Helm** (Kubernetes package manager)

#### Installation

Run the installation script to install all required tools:

```bash
./scripts/install-tools.sh
```

Or install manually:

```bash
# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Terraform
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### 1. AWS configuration

Configure your AWS credentials:

```bash
aws configure
```

Provide:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., us-west-2)
- Default output format (json)

### 2. Local development with Docker

#### Build and run locally with Docker Compose:

```bash
# Start MySQL and Spring Boot application
docker-compose up --build

# Test the application
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "admin123"}'
```

#### Build Docker image only:

```bash
./gradlew clean bootJar
docker build -t springboot-jwt:latest .
```

### 3. AWS EKS deployment

#### Option A: Automated deployment (Recommended)

Use the automated deployment script:

```bash
# Deploy everything (infrastructure + application)
./scripts/deploy.sh

# Clean up resources when done
./scripts/cleanup.sh
```

#### Option B: Manual deployment

1. **Deploy infrastructure with Terraform:**

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

2. **Configure kubectl:**

```bash
aws eks update-kubeconfig --region us-west-2 --name springboot-jwt-cluster
```

3. **Build and push Docker image to ECR:**

```bash
# Get ECR repository URL from Terraform output
ECR_REPO=$(terraform output -raw ecr_repository_url)

# Login to ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $ECR_REPO

# Build and push image
./gradlew clean bootJar
docker build -t springboot-jwt:latest .
docker tag springboot-jwt:latest $ECR_REPO:latest
docker push $ECR_REPO:latest
```

4. **Update Kubernetes manifests:**

```bash
# Update image URL in deployment manifest
sed -i "s|YOUR_ECR_REPO_URI/springboot-jwt:latest|$ECR_REPO:latest|g" k8s/springboot-deployment.yaml

# Update IAM role ARN
ROLE_ARN=$(terraform output -raw springboot_iam_role_arn)
sed -i "s|arn:aws:iam::ACCOUNT_ID:role/SpringBootEKSRole|$ROLE_ARN|g" k8s/springboot-deployment.yaml
```

5. **Deploy to Kubernetes:**

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/mysql.yaml
kubectl apply -f k8s/springboot-deployment.yaml
```

6. **Get LoadBalancer URL:**

```bash
kubectl get svc springboot-service -n springboot-jwt
```

### 4. Architecture

#### Infrastructure Components:
- **VPC** with public and private subnets
- **EKS cluster** with managed node groups
- **ECR repository** for Docker images
- **Application Load Balancer** for external access
- **IAM roles** for secure access (IRSA)
- **RDS MySQL** (or containerized MySQL)

#### Security:
- **IAM Roles for Service Accounts (IRSA)** for fine-grained access control
- **Network policies** for pod-to-pod communication
- **Secrets management** for sensitive data
- **Security groups** and **NACLs** for network security
- **Pod security** for container security

### 5. Configuration

#### Environment variables

The application uses the following environment variables in Kubernetes:

```yaml
env:
- name: SPRING_PROFILES_ACTIVE
  value: "docker"
- name: DB_HOST
  value: "mysql-service"
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: mysql-secret
      key: mysql-root-password
- name: JWT_SECRET
  valueFrom:
    secretKeyRef:
      name: jwt-secret
      key: jwt-secret
```

#### Secrets

Kubernetes secrets are used for:
- Database credentials
- JWT signing key
- Application configuration

### 6. Monitoring and health checks

#### Health Check endpoints:
- **Liveness Probe**: `/actuator/health`
- **Readiness Probe**: `/actuator/health`
- **Startup Probe**: `/actuator/health`

#### Monitoring:
```bash
# Check pod status
kubectl get pods -n springboot-jwt

# Check logs
kubectl logs -f deployment/springboot-deployment -n springboot-jwt

# Check service status
kubectl get svc -n springboot-jwt
```

### 7. Scaling and performance

#### Horizontal Pod Autoscaler:
```bash
kubectl autoscale deployment springboot-deployment --cpu-percent=70 --min=2 --max=10 -n springboot-jwt
```

#### Resource limits:
```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "1Gi"
    cpu: "500m"
```

### 8. Alternative deployment options

#### Option 1: AWS App Runner (Serverless)
For simpler deployment without Kubernetes:

```bash
# Build and push to ECR
aws apprunner create-service --service-name springboot-jwt \
  --source-configuration '{
    "ImageRepository": {
      "ImageIdentifier": "YOUR_ECR_REPO:latest",
      "ImageConfiguration": {
        "Port": "8080",
        "RuntimeEnvironmentVariables": {
          "SPRING_PROFILES_ACTIVE": "docker"
        }
      },
      "ImageRepositoryType": "ECR"
    },
    "AutoDeploymentsEnabled": true
  }'
```

#### Option 2: AWS ECS with Fargate
For containerized deployment without Kubernetes management:

```bash
# Create ECS cluster
aws ecs create-cluster --cluster-name springboot-jwt-cluster

# Create task definition and service
# (Use provided ECS task definition in ecs/ directory)
```

### 9. Cost optimization

#### Development:
- Use **t3.small** or **t3.medium** instances
- **Single AZ** deployment
- **On-Demand** pricing

#### Production:
- Use **t3.medium** or **m5.large** instances
- **Multi-AZ** deployment for high availability
- **Spot Instances** for cost savings (non-critical workloads)
- **Reserved Instances** for predictable workloads

### 10. Security

#### IAM:
- Use **IAM Roles for Service Accounts (IRSA)** instead of embedding credentials
- Follow **principle of least privilege**
- Enable **AWS CloudTrail** for audit logging

#### Network security:
- Use **private subnets** for application workloads
- Configure **security groups** to allow only necessary traffic
- Enable **VPC Flow Logs** for network monitoring

#### Container security:
- Use **non-root users** in containers
- Scan images for vulnerabilities with **ECR image scanning**
- Keep base images **updated**

### 11. Troubleshooting

#### Issues:

1. **Pod not starting:**
   ```bash
   kubectl describe pod <pod-name> -n springboot-jwt
   kubectl logs <pod-name> -n springboot-jwt
   ```

2. **Database connection issues:**
   ```bash
   kubectl exec -it <springboot-pod> -n springboot-jwt -- nc -zv mysql-service 3306
   ```

3. **LoadBalancer not accessible:**
   ```bash
   kubectl get svc springboot-service -n springboot-jwt -o wide
   ```

4. **ECR authentication issues:**
   ```bash
   aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <ecr-repo-url>
   ```

### 12. Cleanup

To avoid AWS charges, clean up resources:

```bash
# Automated cleanup
./scripts/cleanup.sh

# Manual cleanup
kubectl delete namespace springboot-jwt
cd terraform && terraform destroy
```

### 13. Testing the deployed Spring Boot application

Once deployed, test the application:

```bash
# Get LoadBalancer URL
LB_URL=$(kubectl get svc springboot-service -n springboot-jwt -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Health check
curl http://$LB_URL/actuator/health

# Login as admin
curl -X POST http://$LB_URL/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "admin123"}'

# Use the returned JWT token for authenticated requests
TOKEN="<jwt-token-from-login>"
curl -X GET http://$LB_URL/api/admin/users \
  -H "Authorization: Bearer $TOKEN"
```

This comprehensive guide provides multiple deployment options from simple containerization to full Kubernetes deployment on AWS EKS with infrastructure as code using Terraform.
