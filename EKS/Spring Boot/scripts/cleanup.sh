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

echo -e "${YELLOW}Cleaning up resources...${NC}"

# Delete Kubernetes resources
echo -e "${YELLOW}Deleting Kubernetes resources...${NC}"
kubectl delete -f k8s/springboot-deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/mysql.yaml --ignore-not-found=true
kubectl delete -f k8s/secrets.yaml --ignore-not-found=true
kubectl delete -f k8s/namespace.yaml --ignore-not-found=true

echo -e "${GREEN}Kubernetes resources deleted.${NC}"

# Destroy Terraform infrastructure
echo -e "${YELLOW}Destroying Terraform infrastructure...${NC}"
cd terraform
terraform destroy -var="aws_region=$AWS_REGION" -var="cluster_name=$CLUSTER_NAME" -auto-approve
cd ..

echo -e "${GREEN}Infrastructure destroyed successfully.${NC}"

# Clean up Docker images (optional)
echo -e "${YELLOW}Cleaning up local Docker images...${NC}"
docker rmi springboot-jwt:latest 2>/dev/null || true
docker system prune -f

echo -e "${GREEN}Cleanup completed successfully!${NC}"
