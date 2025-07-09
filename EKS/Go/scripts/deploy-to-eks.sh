#!/bin/bash

# AWS EKS Deployment Script for Go Application
# This script sets up and deploys the Go application to Amazon EKS

set -e

# Configuration variables - PLEASE UPDATE THESE VALUES
AWS_REGION="us-west-2"  # Change to your preferred region
AWS_ACCOUNT_ID="123456789012"  # Replace with your AWS account ID
CLUSTER_NAME="go-app-cluster"
ECR_REPOSITORY="go-app"
IMAGE_TAG="latest"
DOMAIN_NAME="your-domain.com"  # Replace with your domain
CERTIFICATE_ARN="arn:aws:acm:${AWS_REGION}:${AWS_ACCOUNT_ID}:certificate/your-certificate-id"  # Replace with your ACM certificate ARN

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting EKS deployment for Go application...${NC}"

# Check if required tools are installed
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    command -v aws >/dev/null 2>&1 || { echo -e "${RED}AWS CLI is required but not installed. Aborting.${NC}" >&2; exit 1; }
    command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}kubectl is required but not installed. Aborting.${NC}" >&2; exit 1; }
    command -v docker >/dev/null 2>&1 || { echo -e "${RED}Docker is required but not installed. Aborting.${NC}" >&2; exit 1; }
    command -v eksctl >/dev/null 2>&1 || { echo -e "${RED}eksctl is required but not installed. Aborting.${NC}" >&2; exit 1; }
    
    echo -e "${GREEN}All prerequisites are installed!${NC}"
}

# Create EKS cluster if it doesn't exist
create_eks_cluster() {
    echo -e "${YELLOW}Checking if EKS cluster exists...${NC}"
    
    if ! aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION >/dev/null 2>&1; then
        echo -e "${YELLOW}Creating EKS cluster: $CLUSTER_NAME${NC}"
        eksctl create cluster \
            --name $CLUSTER_NAME \
            --version 1.21 \
            --region $AWS_REGION \
            --nodegroup-name standard-workers \
            --node-type t3.medium \
            --nodes 3 \
            --nodes-min 1 \
            --nodes-max 4 \
            --managed
        
        echo -e "${GREEN}EKS cluster created successfully!${NC}"
    else
        echo -e "${GREEN}EKS cluster already exists!${NC}"
    fi
}

# Configure kubectl to use the EKS cluster
configure_kubectl() {
    echo -e "${YELLOW}Configuring kubectl for EKS cluster...${NC}"
    aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
    echo -e "${GREEN}kubectl configured successfully!${NC}"
}

# Create ECR repository if it doesn't exist
create_ecr_repository() {
    echo -e "${YELLOW}Checking if ECR repository exists...${NC}"
    
    if ! aws ecr describe-repositories --repository-names $ECR_REPOSITORY --region $AWS_REGION >/dev/null 2>&1; then
        echo -e "${YELLOW}Creating ECR repository: $ECR_REPOSITORY${NC}"
        aws ecr create-repository --repository-name $ECR_REPOSITORY --region $AWS_REGION
        echo -e "${GREEN}ECR repository created successfully!${NC}"
    else
        echo -e "${GREEN}ECR repository already exists!${NC}"
    fi
}

# Build and push Docker image to ECR
build_and_push_image() {
    echo -e "${YELLOW}Building and pushing Docker image...${NC}"
    
    # Get ECR login token
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
    
    # Build the Docker image
    docker build -t $ECR_REPOSITORY:$IMAGE_TAG .
    
    # Tag the image for ECR
    docker tag $ECR_REPOSITORY:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG
    
    # Push the image to ECR
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG
    
    echo -e "${GREEN}Docker image pushed to ECR successfully!${NC}"
}

# Install AWS Load Balancer Controller
install_alb_controller() {
    echo -e "${YELLOW}Installing AWS Load Balancer Controller...${NC}"
    
    # Download IAM policy
    curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json
    
    # Create IAM policy
    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file://iam_policy.json \
        --region $AWS_REGION || true
    
    # Create service account
    eksctl create iamserviceaccount \
        --cluster=$CLUSTER_NAME \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --role-name AmazonEKSLoadBalancerControllerRole \
        --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
        --approve \
        --region $AWS_REGION || true
    
    # Install cert-manager
    kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml
    
    # Wait for cert-manager to be ready
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cert-manager -n cert-manager --timeout=300s
    
    # Install AWS Load Balancer Controller
    curl -Lo v2_4_7_full.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.7/v2_4_7_full.yaml
    sed -i.bak -e "s|your-cluster-name|$CLUSTER_NAME|" ./v2_4_7_full.yaml
    kubectl apply -f v2_4_7_full.yaml
    
    # Clean up
    rm -f iam_policy.json v2_4_7_full.yaml v2_4_7_full.yaml.bak
    
    echo -e "${GREEN}AWS Load Balancer Controller installed successfully!${NC}"
}

# Update deployment files with actual values
update_deployment_files() {
    echo -e "${YELLOW}Updating deployment files with actual values...${NC}"
    
    # Update the deployment.yaml file with the correct ECR image URL
    sed -i.bak "s|your-account-id.dkr.ecr.your-region.amazonaws.com/go-app:latest|$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG|g" k8s/deployment.yaml
    
    # Update ingress.yaml with actual domain and certificate ARN
    sed -i.bak "s|your-domain.com|$DOMAIN_NAME|g" k8s/ingress.yaml
    sed -i.bak "s|arn:aws:acm:your-region:your-account-id:certificate/your-certificate-id|$CERTIFICATE_ARN|g" k8s/ingress.yaml
    
    echo -e "${GREEN}Deployment files updated successfully!${NC}"
}

# Deploy the application to Kubernetes
deploy_application() {
    echo -e "${YELLOW}Deploying application to Kubernetes...${NC}"
    
    # Apply all Kubernetes manifests
    kubectl apply -f k8s/namespace.yaml
    kubectl apply -f k8s/configmap.yaml
    kubectl apply -f k8s/secret.yaml
    kubectl apply -f k8s/postgres.yaml
    kubectl apply -f k8s/redis.yaml
    kubectl apply -f k8s/deployment.yaml
    kubectl apply -f k8s/hpa.yaml
    kubectl apply -f k8s/ingress.yaml
    
    echo -e "${GREEN}Application deployed successfully!${NC}"
}

# Wait for deployment to be ready
wait_for_deployment() {
    echo -e "${YELLOW}Waiting for deployment to be ready...${NC}"
    
    kubectl wait --for=condition=available --timeout=600s deployment/go-app-deployment -n go-app
    kubectl wait --for=condition=available --timeout=600s deployment/postgres-deployment -n go-app
    kubectl wait --for=condition=available --timeout=600s deployment/redis-deployment -n go-app
    
    echo -e "${GREEN}All deployments are ready!${NC}"
}

# Display deployment information
show_deployment_info() {
    echo -e "${GREEN}Deployment completed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}Deployment Information:${NC}"
    echo "Cluster Name: $CLUSTER_NAME"
    echo "Region: $AWS_REGION"
    echo "ECR Repository: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG"
    echo ""
    echo -e "${YELLOW}Getting service information:${NC}"
    kubectl get all -n go-app
    echo ""
    echo -e "${YELLOW}Getting ingress information:${NC}"
    kubectl get ingress -n go-app
}

# Main execution
main() {
    check_prerequisites
    create_eks_cluster
    configure_kubectl
    create_ecr_repository
    build_and_push_image
    install_alb_controller
    update_deployment_files
    deploy_application
    wait_for_deployment
    show_deployment_info
}

# Run the main function
main
