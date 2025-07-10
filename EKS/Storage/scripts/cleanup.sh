#!/bin/bash

# Cleanup EKS Resources
# This script cleans up all EKS resources

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CLUSTER_NAME="app-cluster"
REGION="us-west-2"

echo -e "${YELLOW}Cleaning up EKS resources...${NC}"

# Delete applications
echo -e "${YELLOW}Deleting applications...${NC}"
kubectl delete -f k8s/deployments/ --ignore-not-found=true
kubectl delete -f k8s/services/ --ignore-not-found=true
kubectl delete -f k8s/ingress/ --ignore-not-found=true

# Delete storage
echo -e "${YELLOW}Deleting storage resources...${NC}"
kubectl delete -f k8s/storage/ --ignore-not-found=true

# Delete configmaps and secrets
echo -e "${YELLOW}Deleting ConfigMaps and Secrets...${NC}"
kubectl delete -f k8s/configmaps/ --ignore-not-found=true

# Uninstall Helm charts
echo -e "${YELLOW}Uninstalling Helm charts...${NC}"
helm uninstall aws-load-balancer-controller -n kube-system || true
helm uninstall aws-efs-csi-driver -n kube-system || true

# Delete the cluster
echo -e "${YELLOW}Deleting EKS cluster...${NC}"
eksctl delete cluster --name ${CLUSTER_NAME} --region ${REGION}

echo -e "${GREEN}Cleanup completed successfully!${NC}"

echo -e "${YELLOW}Note: You may want to manually delete:${NC}"
echo "1. ECR repositories (if no longer needed)"
echo "2. EFS file systems (if created)"
echo "3. Any remaining Load Balancers"
echo "4. Route53 records (if created)"
