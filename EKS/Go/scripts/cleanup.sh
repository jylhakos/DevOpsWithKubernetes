#!/bin/bash

# Cleanup script for EKS resources
# This script removes all resources created for the Go application

set -e

# Configuration
CLUSTER_NAME="go-app-cluster"
AWS_REGION="us-west-2"
ECR_REPOSITORY="go-app"
NAMESPACE="go-app"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting cleanup of EKS resources...${NC}"

# Remove Kubernetes resources
cleanup_k8s_resources() {
    echo -e "${YELLOW}Removing Kubernetes resources...${NC}"
    
    # Delete all resources in the namespace
    kubectl delete all --all -n $NAMESPACE || true
    kubectl delete ingress --all -n $NAMESPACE || true
    kubectl delete configmap --all -n $NAMESPACE || true
    kubectl delete secret --all -n $NAMESPACE || true
    kubectl delete pvc --all -n $NAMESPACE || true
    kubectl delete hpa --all -n $NAMESPACE || true
    
    # Delete the namespace
    kubectl delete namespace $NAMESPACE || true
    
    echo -e "${GREEN}Kubernetes resources removed!${NC}"
}

# Remove ECR images
cleanup_ecr() {
    echo -e "${YELLOW}Removing ECR images...${NC}"
    
    # Delete all images in the repository
    aws ecr list-images --repository-name $ECR_REPOSITORY --region $AWS_REGION --query 'imageIds[*]' --output json | \
    jq '.[] | select(.imageTag != null) | {imageTag: .imageTag}' | \
    jq -s '.' | \
    aws ecr batch-delete-image --repository-name $ECR_REPOSITORY --region $AWS_REGION --image-ids file:///dev/stdin || true
    
    # Delete the ECR repository
    aws ecr delete-repository --repository-name $ECR_REPOSITORY --region $AWS_REGION --force || true
    
    echo -e "${GREEN}ECR repository and images removed!${NC}"
}

# Remove EKS cluster
cleanup_eks_cluster() {
    echo -e "${YELLOW}Removing EKS cluster...${NC}"
    
    # Delete the cluster using eksctl
    eksctl delete cluster --name $CLUSTER_NAME --region $AWS_REGION
    
    echo -e "${GREEN}EKS cluster removed!${NC}"
}

# Remove IAM roles and policies
cleanup_iam() {
    echo -e "${YELLOW}Removing IAM resources...${NC}"
    
    # Delete the load balancer controller IAM policy
    aws iam delete-policy --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AWSLoadBalancerControllerIAMPolicy || true
    
    echo -e "${GREEN}IAM resources cleaned up!${NC}"
}

# Main cleanup function
main() {
    echo -e "${RED}WARNING: This will delete all resources for the Go application!${NC}"
    echo "This includes:"
    echo "- Kubernetes resources in namespace: $NAMESPACE"
    echo "- ECR repository: $ECR_REPOSITORY"
    echo "- EKS cluster: $CLUSTER_NAME"
    echo "- Related IAM policies"
    echo ""
    
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup_k8s_resources
        cleanup_ecr
        cleanup_eks_cluster
        cleanup_iam
        
        echo -e "${GREEN}Cleanup completed successfully!${NC}"
        echo -e "${YELLOW}Note: Some resources like VPCs, subnets, and security groups created by eksctl may still exist.${NC}"
        echo -e "${YELLOW}Check the AWS console to verify all resources have been removed.${NC}"
    else
        echo -e "${YELLOW}Cleanup cancelled.${NC}"
    fi
}

# Run the main function
main
