#!/bin/bash

# Script to build and push Docker images to ECR
# Usage: ./build-and-push.sh <aws-account-id> <region>

set -e

AWS_ACCOUNT_ID=${1}
AWS_REGION=${2:-"us-west-2"}

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "Usage: $0 <aws-account-id> [region]"
    echo "Example: $0 123456789012 us-west-2"
    exit 1
fi

BACKEND_REPO="typescript-backend"
FRONTEND_REPO="typescript-frontend"

echo "Building and pushing Docker images..."

# Get login token for ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Create ECR repositories if they don't exist
aws ecr describe-repositories --repository-names $BACKEND_REPO --region $AWS_REGION || aws ecr create-repository --repository-name $BACKEND_REPO --region $AWS_REGION
aws ecr describe-repositories --repository-names $FRONTEND_REPO --region $AWS_REGION || aws ecr create-repository --repository-name $FRONTEND_REPO --region $AWS_REGION

# Build and push backend
echo "Building backend image..."
cd ../backend
docker build -t $BACKEND_REPO .
docker tag $BACKEND_REPO:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO:latest

# Build and push frontend
echo "Building frontend image..."
cd ../frontend
docker build -t $FRONTEND_REPO .
docker tag $FRONTEND_REPO:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_REPO:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_REPO:latest

cd ../scripts

echo "Docker images built and pushed successfully!"
echo "Backend image: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO:latest"
echo "Frontend image: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_REPO:latest"
echo ""
echo "Next steps:"
echo "1. Update the image URLs in k8s/backend-deployment.yaml and k8s/frontend-deployment.yaml"
echo "2. Run ./deploy-to-eks.sh to deploy to your EKS cluster"
