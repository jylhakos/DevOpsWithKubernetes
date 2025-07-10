#!/bin/bash

# Build and Push Docker Images to ECR
# This script builds Docker images and pushes them to Amazon ECR

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REGION="us-west-2"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

echo -e "${GREEN}Building and pushing Docker images to ECR...${NC}"

# Login to ECR
echo -e "${YELLOW}Logging in to ECR...${NC}"
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

# Build and push backend
echo -e "${YELLOW}Building backend image...${NC}"
docker build -t backend ./backend
docker tag backend:latest ${ECR_REGISTRY}/backend:latest
docker tag backend:latest ${ECR_REGISTRY}/backend:$(git rev-parse --short HEAD)

echo -e "${YELLOW}Pushing backend image...${NC}"
docker push ${ECR_REGISTRY}/backend:latest
docker push ${ECR_REGISTRY}/backend:$(git rev-parse --short HEAD)

# Build and push frontend
echo -e "${YELLOW}Building frontend image...${NC}"
docker build -t frontend ./frontend
docker tag frontend:latest ${ECR_REGISTRY}/frontend:latest
docker tag frontend:latest ${ECR_REGISTRY}/frontend:$(git rev-parse --short HEAD)

echo -e "${YELLOW}Pushing frontend image...${NC}"
docker push ${ECR_REGISTRY}/frontend:latest
docker push ${ECR_REGISTRY}/frontend:$(git rev-parse --short HEAD)

# Update deployment files with correct image URLs
echo -e "${YELLOW}Updating deployment files with ECR URLs...${NC}"
sed -i "s/YOUR_ACCOUNT_ID/${AWS_ACCOUNT_ID}/g" k8s/deployments/backend-deployment.yaml
sed -i "s/YOUR_ACCOUNT_ID/${AWS_ACCOUNT_ID}/g" k8s/deployments/frontend-deployment.yaml

echo -e "${GREEN}Docker images built and pushed successfully!${NC}"
echo ""
echo -e "${YELLOW}Image URLs:${NC}"
echo "Backend: ${ECR_REGISTRY}/backend:latest"
echo "Frontend: ${ECR_REGISTRY}/frontend:latest"
echo ""
echo -e "${YELLOW}Next step: Run ./scripts/deploy-apps.sh to deploy to Kubernetes${NC}"
