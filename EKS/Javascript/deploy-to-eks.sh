#!/bin/bash

# AWS EKS React Frontend Deployment Script
# This script deploys a React frontend application to Amazon EKS

set -e

# Configuration
AWS_REGION="us-east-1"  # Change to your preferred region
CLUSTER_NAME="react-frontend-cluster"
ECR_REPO_NAME="react-frontend"
IMAGE_TAG="latest"
NAMESPACE="react-frontend"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if required tools are installed
check_prerequisites() {
    echo_info "Checking prerequisites..."
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        echo_error "AWS CLI not found. Please install it first."
        exit 1
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        echo_error "kubectl not found. Please install it first."
        exit 1
    fi
    
    # Check eksctl
    if ! command -v eksctl &> /dev/null; then
        echo_error "eksctl not found. Please install it first."
        exit 1
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo_error "Docker not found. Please install it first."
        exit 1
    fi
    
    echo_info "All prerequisites are installed."
}

# Function to get AWS account ID
get_aws_account_id() {
    aws sts get-caller-identity --query Account --output text
}

# Function to create ECR repository if it doesn't exist
create_ecr_repo() {
    echo_info "Creating ECR repository if it doesn't exist..."
    
    if ! aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $AWS_REGION &> /dev/null; then
        aws ecr create-repository --repository-name $ECR_REPO_NAME --region $AWS_REGION
        echo_info "ECR repository '$ECR_REPO_NAME' created."
    else
        echo_info "ECR repository '$ECR_REPO_NAME' already exists."
    fi
}

# Function to build and push Docker image
build_and_push_image() {
    echo_info "Building and pushing Docker image..."
    
    ACCOUNT_ID=$(get_aws_account_id)
    ECR_URI="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG"
    
    # Login to ECR
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
    
    # Build image
    docker build -t $ECR_REPO_NAME:$IMAGE_TAG .
    
    # Tag for ECR
    docker tag $ECR_REPO_NAME:$IMAGE_TAG $ECR_URI
    
    # Push to ECR
    docker push $ECR_URI
    
    echo_info "Image pushed to ECR: $ECR_URI"
    echo "ECR_URI=$ECR_URI" > .env
}

# Function to create EKS cluster
create_eks_cluster() {
    echo_info "Creating EKS cluster..."
    
    if ! eksctl get cluster --name $CLUSTER_NAME --region $AWS_REGION &> /dev/null; then
        eksctl create cluster \
            --name $CLUSTER_NAME \
            --region $AWS_REGION \
            --nodegroup-name linux-nodes \
            --node-type t3.medium \
            --nodes 2 \
            --nodes-min 1 \
            --nodes-max 4 \
            --with-oidc \
            --ssh-access \
            --ssh-public-key ~/.ssh/id_rsa.pub \
            --managed
        
        echo_info "EKS cluster '$CLUSTER_NAME' created."
    else
        echo_info "EKS cluster '$CLUSTER_NAME' already exists."
    fi
    
    # Update kubeconfig
    aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
}

# Function to install AWS Load Balancer Controller
install_alb_controller() {
    echo_info "Installing AWS Load Balancer Controller..."
    
    # Create IAM OIDC identity provider
    eksctl utils associate-iam-oidc-provider --region $AWS_REGION --cluster $CLUSTER_NAME --approve
    
    # Download IAM policy
    curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.4/docs/install/iam_policy.json
    
    # Create IAM policy
    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file://iam_policy.json || true
    
    # Create service account
    eksctl create iamserviceaccount \
        --cluster=$CLUSTER_NAME \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --role-name "AmazonEKSLoadBalancerControllerRole" \
        --attach-policy-arn=arn:aws:iam::$(get_aws_account_id):policy/AWSLoadBalancerControllerIAMPolicy \
        --approve || true
    
    # Install AWS Load Balancer Controller using Helm
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=$CLUSTER_NAME \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller || true
    
    rm -f iam_policy.json
}

# Function to deploy application
deploy_application() {
    echo_info "Deploying React frontend application..."
    
    # Update deployment with correct ECR URI
    ACCOUNT_ID=$(get_aws_account_id)
    ECR_URI="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG"
    
    sed -i "s|your-ecr-repo/react-frontend:latest|$ECR_URI|g" k8s/deployment.yaml
    
    # Apply Kubernetes manifests
    kubectl apply -f k8s/namespace.yaml
    kubectl apply -f k8s/configmap.yaml
    kubectl apply -f k8s/deployment.yaml
    kubectl apply -f k8s/hpa.yaml
    kubectl apply -f k8s/ingress.yaml
    
    echo_info "Application deployed successfully!"
    
    # Wait for deployment to be ready
    kubectl wait --for=condition=available --timeout=300s deployment/react-frontend-deployment -n $NAMESPACE
    
    # Get ingress URL
    echo_info "Waiting for ingress to be ready..."
    sleep 30
    INGRESS_URL=$(kubectl get ingress react-frontend-ingress -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    
    if [ ! -z "$INGRESS_URL" ]; then
        echo_info "Application is accessible at: http://$INGRESS_URL"
    else
        echo_warn "Ingress URL not available yet. Check with: kubectl get ingress -n $NAMESPACE"
    fi
}

# Function to show status
show_status() {
    echo_info "Deployment Status:"
    kubectl get pods -n $NAMESPACE
    kubectl get services -n $NAMESPACE
    kubectl get ingress -n $NAMESPACE
}

# Function to cleanup resources
cleanup() {
    echo_warn "Cleaning up resources..."
    
    read -p "Are you sure you want to delete the EKS cluster and all resources? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Delete Kubernetes resources
        kubectl delete -f k8s/ || true
        
        # Delete EKS cluster
        eksctl delete cluster --name $CLUSTER_NAME --region $AWS_REGION
        
        # Delete ECR repository
        aws ecr delete-repository --repository-name $ECR_REPO_NAME --region $AWS_REGION --force || true
        
        echo_info "Cleanup completed."
    else
        echo_info "Cleanup cancelled."
    fi
}

# Main script logic
case "${1:-deploy}" in
    "prerequisites")
        check_prerequisites
        ;;
    "build")
        check_prerequisites
        create_ecr_repo
        build_and_push_image
        ;;
    "cluster")
        check_prerequisites
        create_eks_cluster
        install_alb_controller
        ;;
    "deploy")
        check_prerequisites
        create_ecr_repo
        build_and_push_image
        create_eks_cluster
        install_alb_controller
        deploy_application
        show_status
        ;;
    "status")
        show_status
        ;;
    "cleanup")
        cleanup
        ;;
    *)
        echo "Usage: $0 {prerequisites|build|cluster|deploy|status|cleanup}"
        echo ""
        echo "Commands:"
        echo "  prerequisites - Check if all required tools are installed"
        echo "  build        - Build and push Docker image to ECR"
        echo "  cluster      - Create EKS cluster and install ALB controller"
        echo "  deploy       - Full deployment (build + cluster + deploy app)"
        echo "  status       - Show deployment status"
        echo "  cleanup      - Delete all resources"
        exit 1
        ;;
esac
