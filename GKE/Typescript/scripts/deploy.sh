#!/bin/bash

# Configuration
PROJECT_ID=${PROJECT_ID:-"your-gcp-project-id"}
CLUSTER_NAME=${CLUSTER_NAME:-"typescript-cluster"}
ZONE=${ZONE:-"us-central1-a"}
BACKEND_IMAGE_TAG=${BACKEND_IMAGE_TAG:-"latest"}
FRONTEND_IMAGE_TAG=${FRONTEND_IMAGE_TAG:-"latest"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if PROJECT_ID is set
check_project_id() {
    if [ "$PROJECT_ID" = "your-gcp-project-id" ]; then
        print_error "Please set PROJECT_ID environment variable or edit this script."
        print_error "Example: export PROJECT_ID=your-actual-project-id"
        exit 1
    fi
}

# Build and push Docker images
build_and_push() {
    print_status "Building and pushing Docker images..."
    
    # Build backend image
    print_status "Building backend image..."
    cd ../backend
    docker build -t gcr.io/$PROJECT_ID/backend:$BACKEND_IMAGE_TAG .
    
    if [ $? -ne 0 ]; then
        print_error "Failed to build backend image."
        exit 1
    fi
    
    # Push backend image
    print_status "Pushing backend image..."
    docker push gcr.io/$PROJECT_ID/backend:$BACKEND_IMAGE_TAG
    
    if [ $? -ne 0 ]; then
        print_error "Failed to push backend image."
        exit 1
    fi
    
    # Build frontend image
    print_status "Building frontend image..."
    cd ../frontend
    docker build -t gcr.io/$PROJECT_ID/frontend:$FRONTEND_IMAGE_TAG .
    
    if [ $? -ne 0 ]; then
        print_error "Failed to build frontend image."
        exit 1
    fi
    
    # Push frontend image
    print_status "Pushing frontend image..."
    docker push gcr.io/$PROJECT_ID/frontend:$FRONTEND_IMAGE_TAG
    
    if [ $? -ne 0 ]; then
        print_error "Failed to push frontend image."
        exit 1
    fi
    
    cd ../scripts
    print_status "Docker images built and pushed successfully."
}

# Update Kubernetes manifests with project ID
update_manifests() {
    print_status "Updating Kubernetes manifests..."
    
    # Update backend deployment
    sed -i "s/YOUR_PROJECT_ID/$PROJECT_ID/g" ../k8s/backend.yaml
    sed -i "s/:latest/:$BACKEND_IMAGE_TAG/g" ../k8s/backend.yaml
    
    # Update frontend deployment
    sed -i "s/YOUR_PROJECT_ID/$PROJECT_ID/g" ../k8s/frontend.yaml
    sed -i "s/:latest/:$FRONTEND_IMAGE_TAG/g" ../k8s/frontend.yaml
    
    print_status "Kubernetes manifests updated successfully."
}

# Deploy to Kubernetes
deploy_to_k8s() {
    print_status "Deploying to Kubernetes..."
    
    # Apply security configurations
    print_status "Applying security configurations..."
    kubectl apply -f ../k8s/security.yaml
    
    if [ $? -ne 0 ]; then
        print_error "Failed to apply security configurations."
        exit 1
    fi
    
    # Deploy backend
    print_status "Deploying backend..."
    kubectl apply -f ../k8s/backend.yaml -n typescript-app
    
    if [ $? -ne 0 ]; then
        print_error "Failed to deploy backend."
        exit 1
    fi
    
    # Deploy frontend
    print_status "Deploying frontend..."
    kubectl apply -f ../k8s/frontend.yaml -n typescript-app
    
    if [ $? -ne 0 ]; then
        print_error "Failed to deploy frontend."
        exit 1
    fi
    
    print_status "Deployment completed successfully."
}

# Wait for deployments to be ready
wait_for_deployments() {
    print_status "Waiting for deployments to be ready..."
    
    kubectl wait --for=condition=available --timeout=300s deployment/backend-deployment -n typescript-app
    kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment -n typescript-app
    
    if [ $? -eq 0 ]; then
        print_status "All deployments are ready."
    else
        print_error "Some deployments are not ready. Check with 'kubectl get pods -n typescript-app'"
    fi
}

# Get service URLs
get_service_urls() {
    print_status "Getting service URLs..."
    
    # Wait for LoadBalancer to get external IP
    print_status "Waiting for LoadBalancer to get external IP..."
    kubectl get service frontend-service -n typescript-app -w &
    WATCH_PID=$!
    
    # Wait up to 5 minutes for external IP
    for i in {1..30}; do
        EXTERNAL_IP=$(kubectl get service frontend-service -n typescript-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        if [ ! -z "$EXTERNAL_IP" ] && [ "$EXTERNAL_IP" != "null" ]; then
            break
        fi
        sleep 10
    done
    
    kill $WATCH_PID 2>/dev/null
    
    if [ ! -z "$EXTERNAL_IP" ] && [ "$EXTERNAL_IP" != "null" ]; then
        print_status "Frontend URL: http://$EXTERNAL_IP"
    else
        print_warning "External IP not assigned yet. Run 'kubectl get service frontend-service -n typescript-app' to check later."
    fi
}

# Show deployment status
show_status() {
    print_status "Deployment Status:"
    echo "===================="
    kubectl get all -n typescript-app
    echo "===================="
    kubectl get hpa -n typescript-app
}

# Main function
main() {
    check_project_id
    build_and_push
    update_manifests
    deploy_to_k8s
    wait_for_deployments
    get_service_urls
    show_status
    
    print_status "Deployment completed successfully!"
    print_warning "It may take a few minutes for the LoadBalancer to assign an external IP."
}

# Run main function
main
