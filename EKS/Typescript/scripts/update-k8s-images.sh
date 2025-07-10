#!/bin/bash

# Script to update Kubernetes deployment files with correct ECR image URLs
# Usage: ./update-k8s-images.sh <aws-account-id> <region>

set -e

AWS_ACCOUNT_ID=${1}
AWS_REGION=${2:-"us-west-2"}

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "Usage: $0 <aws-account-id> [region]"
    echo "Example: $0 123456789012 us-west-2"
    exit 1
fi

BACKEND_IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/typescript-backend:latest"
FRONTEND_IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/typescript-frontend:latest"

echo "Updating Kubernetes deployment files with ECR image URLs..."

# Update backend deployment
sed -i "s|your-account-id.dkr.ecr.region.amazonaws.com/typescript-backend:latest|$BACKEND_IMAGE|g" ../k8s/backend-deployment.yaml

# Update frontend deployment
sed -i "s|your-account-id.dkr.ecr.region.amazonaws.com/typescript-frontend:latest|$FRONTEND_IMAGE|g" ../k8s/frontend-deployment.yaml

echo "Kubernetes deployment files updated successfully!"
echo "Backend image: $BACKEND_IMAGE"
echo "Frontend image: $FRONTEND_IMAGE"
echo ""
echo "Files updated:"
echo "- k8s/backend-deployment.yaml"
echo "- k8s/frontend-deployment.yaml"
