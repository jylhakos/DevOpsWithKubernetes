#!/bin/bash

# GKE Deployment Script
# This script builds Docker images and deploys to Google Kubernetes Engine

set -e

# Configuration - Update these values
PROJECT_ID="your-gcp-project-id"
CLUSTER_NAME="myapp-cluster"
ZONE="us-central1-a"
REGION="us-central1"

# Image tags
BACKEND_IMAGE="gcr.io/${PROJECT_ID}/backend"
FRONTEND_IMAGE="gcr.io/${PROJECT_ID}/frontend"
TAG="latest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Function to check if required tools are installed
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    local missing_tools=()
    
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    fi
    
    if ! command -v gcloud &> /dev/null; then
        missing_tools+=("gcloud")
    fi
    
    if ! command -v kubectl &> /dev/null; then
        missing_tools+=("kubectl")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_error "Please run ./setup.sh first"
        exit 1
    fi
    
    print_status "All prerequisites are met"
}

# Function to authenticate and set project
setup_gcp() {
    print_step "Setting up GCP configuration..."
    
    # Check if already authenticated
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_warning "Not authenticated with GCP. Please run: gcloud auth login"
        exit 1
    fi
    
    # Set project
    gcloud config set project $PROJECT_ID
    
    # Enable required APIs
    print_status "Enabling required GCP APIs..."
    gcloud services enable container.googleapis.com
    gcloud services enable compute.googleapis.com
    gcloud services enable containerregistry.googleapis.com
    
    print_status "GCP setup completed"
}

# Function to create GKE cluster
create_cluster() {
    print_step "Creating GKE cluster..."
    
    # Check if cluster already exists
    if gcloud container clusters describe $CLUSTER_NAME --zone=$ZONE &> /dev/null; then
        print_status "Cluster $CLUSTER_NAME already exists"
    else
        print_status "Creating cluster $CLUSTER_NAME..."
        gcloud container clusters create $CLUSTER_NAME \
            --zone=$ZONE \
            --machine-type=e2-standard-2 \
            --num-nodes=3 \
            --enable-autoscaling \
            --min-nodes=1 \
            --max-nodes=10 \
            --enable-autorepair \
            --enable-autoupgrade \
            --disk-size=20GB \
            --disk-type=pd-standard \
            --enable-ip-alias \
            --network=default \
            --subnetwork=default \
            --enable-network-policy \
            --addons=HorizontalPodAutoscaling,HttpLoadBalancing,NetworkPolicy
        
        print_status "Cluster created successfully"
    fi
    
    # Get cluster credentials
    gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE
    print_status "Cluster credentials configured"
}

# Function to reserve static IP addresses
setup_static_ips() {
    print_step "Setting up static IP addresses..."
    
    # Reserve IP for backend
    if ! gcloud compute addresses describe backend-ip --global &> /dev/null; then
        gcloud compute addresses create backend-ip --global
        print_status "Backend IP address reserved"
    else
        print_status "Backend IP address already exists"
    fi
    
    # Reserve IP for frontend
    if ! gcloud compute addresses describe frontend-ip --global &> /dev/null; then
        gcloud compute addresses create frontend-ip --global
        print_status "Frontend IP address reserved"
    else
        print_status "Frontend IP address already exists"
    fi
    
    # Display IP addresses
    echo ""
    print_status "Reserved IP addresses:"
    echo "Backend IP: $(gcloud compute addresses describe backend-ip --global --format='value(address)')"
    echo "Frontend IP: $(gcloud compute addresses describe frontend-ip --global --format='value(address)')"
    echo ""
}

# Function to build and push Docker images
build_and_push_images() {
    print_step "Building and pushing Docker images..."
    
    # Configure Docker to use gcloud as a credential helper
    gcloud auth configure-docker
    
    # Build backend image
    print_status "Building backend image..."
    cd backend
    docker build -t $BACKEND_IMAGE:$TAG .
    docker push $BACKEND_IMAGE:$TAG
    cd ..
    print_status "Backend image pushed successfully"
    
    # Build frontend image
    print_status "Building frontend image..."
    cd frontend
    docker build -t $FRONTEND_IMAGE:$TAG .
    docker push $FRONTEND_IMAGE:$TAG
    cd ..
    print_status "Frontend image pushed successfully"
}

# Function to update Kubernetes manifests with project ID
update_manifests() {
    print_step "Updating Kubernetes manifests..."
    
    # Update backend deployment
    sed -i "s/PROJECT_ID/$PROJECT_ID/g" k8s/backend.yaml
    sed -i "s/PROJECT_ID/$PROJECT_ID/g" k8s/frontend.yaml
    
    print_status "Manifests updated with project ID: $PROJECT_ID"
}

# Function to deploy to Kubernetes
deploy_to_k8s() {
    print_step "Deploying to Kubernetes..."
    
    # Apply manifests in order
    kubectl apply -f k8s/namespace.yaml
    kubectl apply -f k8s/configmap.yaml
    kubectl apply -f k8s/security.yaml
    kubectl apply -f k8s/postgres.yaml
    kubectl apply -f k8s/redis.yaml
    kubectl apply -f k8s/backend.yaml
    kubectl apply -f k8s/frontend.yaml
    kubectl apply -f k8s/scaling.yaml
    
    print_status "All manifests applied successfully"
    
    # Wait for deployments to be ready
    print_status "Waiting for deployments to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/postgres-deployment -n myapp-namespace
    kubectl wait --for=condition=available --timeout=300s deployment/redis-deployment -n myapp-namespace
    kubectl wait --for=condition=available --timeout=300s deployment/backend-deployment -n myapp-namespace
    kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment -n myapp-namespace
    
    print_status "All deployments are ready!"
}

# Function to display deployment status
show_status() {
    print_step "Deployment Status"
    
    echo ""
    print_status "Pods:"
    kubectl get pods -n myapp-namespace
    
    echo ""
    print_status "Services:"
    kubectl get services -n myapp-namespace
    
    echo ""
    print_status "Ingresses:"
    kubectl get ingress -n myapp-namespace
    
    echo ""
    print_status "External IP addresses:"
    echo "Backend IP: $(gcloud compute addresses describe backend-ip --global --format='value(address)')"
    echo "Frontend IP: $(gcloud compute addresses describe frontend-ip --global --format='value(address)')"
    
    echo ""
    print_status "To check your application:"
    echo "1. Update your DNS to point your domains to the above IP addresses"
    echo "2. Update the domains in k8s/backend.yaml and k8s/frontend.yaml"
    echo "3. Test the backend: curl https://your-backend-domain.com/ping"
    echo "4. Test Redis: curl https://your-backend-domain.com/ping?redis=true"
    echo "5. Test PostgreSQL: curl https://your-backend-domain.com/ping?postgres=true"
}

# Main execution
main() {
    print_status "🚀 Starting GKE deployment process..."
    
    check_prerequisites
    setup_gcp
    create_cluster
    setup_static_ips
    build_and_push_images
    update_manifests
    deploy_to_k8s
    show_status
    
    print_status "✅ Deployment completed successfully!"
}

# Check if config values are set
if [ "$PROJECT_ID" = "your-gcp-project-id" ]; then
    print_error "Please update the PROJECT_ID in this script before running"
    exit 1
fi

# Run main function
main "$@"
