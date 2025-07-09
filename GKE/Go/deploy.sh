#!/bin/bash

# GKE Deployment Script for Go Application
# This script deploys the Go application with PostgreSQL and Redis to Google GKE

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="${PROJECT_ID:-your-gcp-project-id}"  # Set your GCP project ID
CLUSTER_NAME="${CLUSTER_NAME:-go-app-cluster}"
REGION="${REGION:-us-central1-a}"
IMAGE_NAME="go-app"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo -e "${GREEN}🚀 Starting deployment to GKE...${NC}"

# Function to print status
print_status() {
    echo -e "${YELLOW}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if required tools are installed
check_tools() {
    print_status "Checking required tools..."
    
    tools=("docker" "gcloud" "kubectl")
    for tool in "${tools[@]}"; do
        if ! command -v $tool &> /dev/null; then
            print_error "$tool is not installed. Please install it first."
            exit 1
        fi
    done
    print_success "All required tools are installed"
}

# Build and push Docker image
build_and_push_image() {
    print_status "Building and pushing Docker image..."
    
    # Build the image
    docker build -t gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG .
    
    # Configure Docker to use gcloud as a credential helper
    gcloud auth configure-docker
    
    # Push the image to Google Container Registry
    docker push gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG
    
    print_success "Docker image built and pushed successfully"
}

# Create GKE cluster if it doesn't exist
create_cluster() {
    print_status "Checking if GKE cluster exists..."
    
    if gcloud container clusters describe $CLUSTER_NAME --zone=$REGION --project=$PROJECT_ID &> /dev/null; then
        print_success "Cluster $CLUSTER_NAME already exists"
    else
        print_status "Creating GKE cluster..."
        gcloud container clusters create $CLUSTER_NAME \
            --zone=$REGION \
            --project=$PROJECT_ID \
            --machine-type=e2-medium \
            --num-nodes=3 \
            --enable-autoscaling \
            --min-nodes=1 \
            --max-nodes=5 \
            --enable-autorepair \
            --enable-autoupgrade
        print_success "GKE cluster created successfully"
    fi
}

# Get cluster credentials
get_credentials() {
    print_status "Getting cluster credentials..."
    gcloud container clusters get-credentials $CLUSTER_NAME --zone=$REGION --project=$PROJECT_ID
    print_success "Cluster credentials configured"
}

# Update deployment with correct image
update_deployment() {
    print_status "Updating deployment with correct image..."
    sed -i "s|gcr.io/YOUR_PROJECT_ID/go-app:latest|gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG|g" k8s/go-app-deployment.yaml
    print_success "Deployment updated with correct image"
}

# Deploy to Kubernetes
deploy_to_k8s() {
    print_status "Deploying to Kubernetes..."
    
    # Apply all manifests in order
    kubectl apply -f k8s/namespace.yaml
    kubectl apply -f k8s/configmap.yaml
    kubectl apply -f k8s/secret.yaml
    kubectl apply -f k8s/postgres-pvc.yaml
    kubectl apply -f k8s/redis-pvc.yaml
    kubectl apply -f k8s/postgres.yaml
    kubectl apply -f k8s/redis.yaml
    kubectl apply -f k8s/go-app-deployment.yaml
    kubectl apply -f k8s/go-app-service.yaml
    kubectl apply -f k8s/ingress.yaml
    kubectl apply -f k8s/hpa.yaml
    
    print_success "All manifests applied successfully"
}

# Wait for deployments
wait_for_deployments() {
    print_status "Waiting for deployments to be ready..."
    
    kubectl wait --for=condition=available --timeout=300s deployment/postgres-deployment -n go-app
    kubectl wait --for=condition=available --timeout=300s deployment/redis-deployment -n go-app
    kubectl wait --for=condition=available --timeout=300s deployment/go-app-deployment -n go-app
    
    print_success "All deployments are ready"
}

# Show deployment status
show_status() {
    print_status "Deployment Status:"
    echo ""
    echo "Pods:"
    kubectl get pods -n go-app
    echo ""
    echo "Services:"
    kubectl get services -n go-app
    echo ""
    echo "Ingress:"
    kubectl get ingress -n go-app
    echo ""
    echo "External IP (may take a few minutes to be assigned):"
    kubectl get ingress go-app-ingress -n go-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
    echo ""
}

# Main execution
main() {
    echo -e "${GREEN}🎯 GKE Deployment Script${NC}"
    echo -e "${YELLOW}Project ID: $PROJECT_ID${NC}"
    echo -e "${YELLOW}Cluster: $CLUSTER_NAME${NC}"
    echo -e "${YELLOW}Region: $REGION${NC}"
    echo ""
    
    check_tools
    build_and_push_image
    create_cluster
    get_credentials
    update_deployment
    deploy_to_k8s
    wait_for_deployments
    show_status
    
    echo ""
    print_success "🎉 Deployment completed successfully!"
    echo -e "${YELLOW}📝 Next steps:${NC}"
    echo "1. Wait for the external IP to be assigned to the ingress"
    echo "2. Update your DNS records to point to the external IP"
    echo "3. Monitor the application: kubectl logs -f deployment/go-app-deployment -n go-app"
}

# Run main function
main "$@"
