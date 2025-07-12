#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION=${AWS_REGION:-us-west-2}
CLUSTER_NAME=${CLUSTER_NAME:-springboot-jwt-cluster}
ECR_REPOSITORY_NAME=${ECR_REPOSITORY_NAME:-springboot-jwt}

echo -e "${GREEN}Starting deployment process...${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check required tools
echo -e "${YELLOW}Checking required tools...${NC}"
required_tools=("aws" "docker" "kubectl" "terraform")
for tool in "${required_tools[@]}"; do
    if ! command_exists $tool; then
        echo -e "${RED}Error: $tool is not installed. Please install it first.${NC}"
        exit 1
    fi
done
echo -e "${GREEN}All required tools are installed.${NC}"

# Check AWS credentials
echo -e "${YELLOW}Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo -e "${RED}Error: AWS credentials not configured. Please run 'aws configure' first.${NC}"
    exit 1
fi
echo -e "${GREEN}AWS credentials are configured.${NC}"

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "${GREEN}AWS Account ID: $ACCOUNT_ID${NC}"

# Build Docker image
echo -e "${YELLOW}Building Docker image...${NC}"
./gradlew clean bootJar
docker build -t $ECR_REPOSITORY_NAME:latest .
echo -e "${GREEN}Docker image built successfully.${NC}"

# Initialize and apply Terraform
echo -e "${YELLOW}Deploying infrastructure with Terraform...${NC}"
cd terraform
terraform init
terraform plan -var="aws_region=$AWS_REGION" -var="cluster_name=$CLUSTER_NAME"
terraform apply -var="aws_region=$AWS_REGION" -var="cluster_name=$CLUSTER_NAME" -auto-approve

# Get Terraform outputs
ECR_REPOSITORY_URL=$(terraform output -raw ecr_repository_url)
SPRINGBOOT_IAM_ROLE_ARN=$(terraform output -raw springboot_iam_role_arn)

cd ..

echo -e "${GREEN}Infrastructure deployed successfully.${NC}"

# Configure kubectl
echo -e "${YELLOW}Configuring kubectl...${NC}"
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
echo -e "${GREEN}kubectl configured successfully.${NC}"

# Login to ECR and push image
echo -e "${YELLOW}Pushing Docker image to ECR...${NC}"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY_URL
docker tag $ECR_REPOSITORY_NAME:latest $ECR_REPOSITORY_URL:latest
docker push $ECR_REPOSITORY_URL:latest
echo -e "${GREEN}Docker image pushed to ECR successfully.${NC}"

# Update Kubernetes manifests with actual values
echo -e "${YELLOW}Updating Kubernetes manifests...${NC}"
sed -i "s|YOUR_ECR_REPO_URI/springboot-jwt:latest|$ECR_REPOSITORY_URL:latest|g" k8s/springboot-deployment.yaml
sed -i "s|arn:aws:iam::ACCOUNT_ID:role/SpringBootEKSRole|$SPRINGBOOT_IAM_ROLE_ARN|g" k8s/springboot-deployment.yaml

# Deploy to Kubernetes
echo -e "${YELLOW}Deploying to Kubernetes...${NC}"
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/mysql.yaml
kubectl apply -f k8s/springboot-deployment.yaml

# Wait for deployment to be ready
echo -e "${YELLOW}Waiting for deployments to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/mysql-deployment -n springboot-jwt
kubectl wait --for=condition=available --timeout=300s deployment/springboot-deployment -n springboot-jwt

# Get LoadBalancer URL
echo -e "${YELLOW}Getting LoadBalancer URL...${NC}"
LOAD_BALANCER_URL=$(kubectl get svc springboot-service -n springboot-jwt -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}LoadBalancer URL: http://$LOAD_BALANCER_URL${NC}"
echo -e "${GREEN}Health Check: http://$LOAD_BALANCER_URL/actuator/health${NC}"
echo -e "${GREEN}API Login: http://$LOAD_BALANCER_URL/api/auth/login${NC}"

echo -e "${YELLOW}Test the application with:${NC}"
echo "curl -X POST http://$LOAD_BALANCER_URL/api/auth/login -H \"Content-Type: application/json\" -d '{\"email\": \"admin@example.com\", \"password\": \"admin123\"}'"
