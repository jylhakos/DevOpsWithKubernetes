#!/bin/bash

# ML Pipeline EKS Deployment Script
set -e

# Configuration
CLUSTER_NAME="ml-pipeline-cluster"
REGION="us-west-2"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

echo "Starting ML Pipeline deployment to EKS..."
echo "Cluster: $CLUSTER_NAME"
echo "Region: $REGION"
echo "Account ID: $ACCOUNT_ID"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "Checking prerequisites..."
for cmd in aws kubectl eksctl docker helm; do
    if ! command_exists "$cmd"; then
        echo "Error: $cmd is not installed"
        exit 1
    fi
done

# Create ECR repositories if they don't exist
echo "Creating ECR repositories..."
for repo in ml-training ml-backend ml-frontend; do
    aws ecr describe-repositories --repository-names $repo --region $REGION >/dev/null 2>&1 || \
    aws ecr create-repository --repository-name $repo --region $REGION
done

# Login to ECR
echo "Logging into ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Build and push Docker images
echo "Building and pushing Docker images..."

echo "Building ml-training..."
docker build -t ml-training ./ml-training
docker tag ml-training:latest $ECR_REGISTRY/ml-training:latest
docker push $ECR_REGISTRY/ml-training:latest

echo "Building ml-backend..."
docker build -t ml-backend ./ml-backend
docker tag ml-backend:latest $ECR_REGISTRY/ml-backend:latest
docker push $ECR_REGISTRY/ml-backend:latest

echo "Building ml-frontend..."
docker build -t ml-frontend ./ml-frontend
docker tag ml-frontend:latest $ECR_REGISTRY/ml-frontend:latest
docker push $ECR_REGISTRY/ml-frontend:latest

# Update Kubernetes manifests with correct image URLs
echo "Updating Kubernetes manifests..."
find k8s/ -name "*.yaml" -exec sed -i "s|your-ecr-repo|$ECR_REGISTRY|g" {} \;

# Apply Kubernetes manifests
echo "Deploying to Kubernetes..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/rbac.yaml
kubectl apply -f k8s/efs-storageclass.yaml
kubectl apply -f k8s/storage.yaml

# Wait a moment for storage to be ready
sleep 10

kubectl apply -f k8s/ml-training-job.yaml
kubectl apply -f k8s/ml-backend.yaml
kubectl apply -f k8s/ml-frontend.yaml
kubectl apply -f k8s/hpa.yaml

# Wait for deployments to be ready
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/ml-backend -n ml-pipeline
kubectl wait --for=condition=available --timeout=300s deployment/ml-frontend -n ml-pipeline

# Apply ingress (optional)
if [ -f "k8s/ingress.yaml" ]; then
    kubectl apply -f k8s/ingress.yaml
fi

echo "Deployment completed successfully!"
echo "Check the status with: kubectl get all -n ml-pipeline"
echo "Training job logs: kubectl logs -f job/ml-training-job -n ml-pipeline"
echo "Backend logs: kubectl logs -f deployment/ml-backend -n ml-pipeline"
echo "Frontend logs: kubectl logs -f deployment/ml-frontend -n ml-pipeline"

# Get service URLs
echo ""
echo "Service URLs:"
kubectl get svc -n ml-pipeline
