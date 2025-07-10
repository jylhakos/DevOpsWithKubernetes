#!/bin/bash

# Setup EKS Cluster Script
# This script creates an EKS cluster with all necessary components

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="app-cluster"
REGION="us-west-2"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo -e "${GREEN}Starting EKS cluster setup...${NC}"

# Check if AWS CLI is configured
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo -e "${RED}Error: AWS CLI is not configured. Please run 'aws configure' first.${NC}"
    exit 1
fi

echo -e "${YELLOW}Creating EKS cluster: ${CLUSTER_NAME}${NC}"
# Create the cluster
eksctl create cluster -f k8s/cluster/cluster-config.yaml

echo -e "${YELLOW}Installing AWS Load Balancer Controller...${NC}"
# Install AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=${CLUSTER_NAME} \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

echo -e "${YELLOW}Installing EFS CSI Driver...${NC}"
# Install EFS CSI Driver
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
helm repo update

helm install aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
  --namespace kube-system \
  --set serviceAccount.controller.create=false \
  --set serviceAccount.controller.name=efs-csi-controller-sa

echo -e "${YELLOW}Creating ECR repositories...${NC}"
# Create ECR repositories
aws ecr create-repository --repository-name backend --region ${REGION} || true
aws ecr create-repository --repository-name frontend --region ${REGION} || true

echo -e "${YELLOW}Setting up storage classes...${NC}"
# Apply storage classes
kubectl apply -f k8s/storage/storage-class.yaml

echo -e "${YELLOW}Creating persistent volume claims...${NC}"
# Apply PVCs
kubectl apply -f k8s/storage/postgres-pvc.yaml

echo -e "${YELLOW}Creating ConfigMaps and Secrets...${NC}"
# Apply ConfigMaps and Secrets
kubectl apply -f k8s/configmaps/app-config.yaml

echo -e "${GREEN}EKS cluster setup completed successfully!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Update the deployment files with your ECR repository URLs"
echo "2. Run ./scripts/build-and-push.sh to build and push Docker images"
echo "3. Run ./scripts/deploy-apps.sh to deploy your applications"
echo ""
echo -e "${YELLOW}Cluster information:${NC}"
kubectl cluster-info
echo ""
echo -e "${YELLOW}ECR repositories:${NC}"
echo "Backend: ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/backend"
echo "Frontend: ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/frontend"
