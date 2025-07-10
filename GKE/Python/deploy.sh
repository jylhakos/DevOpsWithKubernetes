#!/bin/bash

# ML App GKE Deployment Script
# This script deploys the ML application to Google Kubernetes Engine

set -e

# Configuration
PROJECT_ID="${PROJECT_ID:-your-gcp-project-id}"
CLUSTER_NAME="${CLUSTER_NAME:-ml-app-cluster}"
ZONE="${ZONE:-us-central1-a}"
REGION="${REGION:-us-central1}"

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

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v gcloud &> /dev/null; then
        print_error "gcloud CLI is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install it first."
        exit 1
    fi
    
    print_status "Prerequisites check passed!"
}

# Set up GCP project and authentication
setup_gcp() {
    print_status "Setting up GCP project and authentication..."
    
    # Set project
    gcloud config set project $PROJECT_ID
    
    # Enable required APIs
    print_status "Enabling required GCP APIs..."
    gcloud services enable container.googleapis.com
    gcloud services enable containerregistry.googleapis.com
    gcloud services enable storage-api.googleapis.com
    gcloud services enable iam.googleapis.com
    
    # Configure Docker to use gcloud as a credential helper
    gcloud auth configure-docker
}

# Create GKE cluster
create_cluster() {
    print_status "Creating GKE cluster: $CLUSTER_NAME"
    
    # Check if cluster already exists
    if gcloud container clusters describe $CLUSTER_NAME --zone=$ZONE &> /dev/null; then
        print_warning "Cluster $CLUSTER_NAME already exists. Skipping creation."
        return
    fi
    
    gcloud container clusters create $CLUSTER_NAME \
        --zone=$ZONE \
        --num-nodes=3 \
        --enable-autoscaling \
        --min-nodes=1 \
        --max-nodes=5 \
        --enable-autorepair \
        --enable-autoupgrade \
        --machine-type=e2-standard-4 \
        --disk-size=50GB \
        --enable-ip-alias \
        --enable-workload-identity \
        --enable-shielded-nodes
    
    # Get cluster credentials
    gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE
}

# Create GCP service account and configure Workload Identity
setup_workload_identity() {
    print_status "Setting up Workload Identity..."
    
    # Create GCP service account
    gcloud iam service-accounts create ml-app-gsa \
        --display-name="ML App Service Account" || true
    
    # Grant necessary permissions
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:ml-app-gsa@$PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/storage.admin"
    
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:ml-app-gsa@$PROJECT_ID.iam.gserviceaccount.com" \
        --role="roles/ml.admin"
    
    # Allow Kubernetes service account to impersonate GCP service account
    gcloud iam service-accounts add-iam-policy-binding \
        --role roles/iam.workloadIdentityUser \
        --member "serviceAccount:$PROJECT_ID.svc.id.goog[ml-app/ml-service-account]" \
        ml-app-gsa@$PROJECT_ID.iam.gserviceaccount.com
}

# Build and push Docker images
build_and_push_images() {
    print_status "Building and pushing Docker images..."
    
    # Build and push training image
    print_status "Building ml-training image..."
    docker build -t gcr.io/$PROJECT_ID/ml-training:latest ./ml-training
    docker push gcr.io/$PROJECT_ID/ml-training:latest
    
    # Build and push backend image
    print_status "Building ml-backend image..."
    docker build -t gcr.io/$PROJECT_ID/ml-backend:latest ./ml-backend
    docker push gcr.io/$PROJECT_ID/ml-backend:latest
    
    # Build and push frontend image
    print_status "Building ml-frontend image..."
    docker build -t gcr.io/$PROJECT_ID/ml-frontend:latest ./ml-frontend
    docker push gcr.io/$PROJECT_ID/ml-frontend:latest
}

# Update Kubernetes manifests with project ID
update_manifests() {
    print_status "Updating Kubernetes manifests with project ID..."
    
    # Create temporary directory for updated manifests
    mkdir -p ./kubernetes/temp
    
    # Update all YAML files
    for file in ./kubernetes/*.yaml; do
        if [[ -f "$file" ]]; then
            sed "s/PROJECT_ID/$PROJECT_ID/g" "$file" > "./kubernetes/temp/$(basename $file)"
        fi
    done
}

# Deploy to Kubernetes
deploy_to_kubernetes() {
    print_status "Deploying to Kubernetes..."
    
    # Apply manifests in order
    kubectl apply -f ./kubernetes/temp/00-namespace-rbac.yaml
    kubectl apply -f ./kubernetes/temp/01-storage.yaml
    kubectl apply -f ./kubernetes/temp/02-config.yaml
    
    # Wait for namespace to be ready
    kubectl wait --for=condition=Ready namespace/ml-app --timeout=60s
    
    # Deploy training job
    kubectl apply -f ./kubernetes/temp/03-training-job.yaml
    
    # Wait for training job to complete
    print_status "Waiting for training job to complete..."
    kubectl wait --for=condition=complete job/ml-training-job -n ml-app --timeout=1800s
    
    # Deploy backend and frontend
    kubectl apply -f ./kubernetes/temp/04-backend.yaml
    kubectl apply -f ./kubernetes/temp/05-frontend.yaml
    kubectl apply -f ./kubernetes/temp/06-ingress.yaml
    
    # Wait for deployments to be ready
    kubectl wait --for=condition=available deployment/ml-backend -n ml-app --timeout=300s
    kubectl wait --for=condition=available deployment/ml-frontend -n ml-app --timeout=300s
}

# Get application URLs
get_urls() {
    print_status "Getting application URLs..."
    
    # Get external IP
    EXTERNAL_IP=$(kubectl get service ml-frontend-service -n ml-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    
    if [[ -n "$EXTERNAL_IP" ]]; then
        print_status "Application is available at: http://$EXTERNAL_IP:3000"
    else
        print_warning "External IP not yet assigned. Check again in a few minutes with:"
        echo "kubectl get service ml-frontend-service -n ml-app"
    fi
}

# Cleanup function
cleanup() {
    rm -rf ./kubernetes/temp
}

# Main execution
main() {
    print_status "Starting ML App deployment to GKE..."
    
    check_prerequisites
    setup_gcp
    create_cluster
    setup_workload_identity
    build_and_push_images
    update_manifests
    deploy_to_kubernetes
    get_urls
    cleanup
    
    print_status "Deployment completed successfully!"
}

# Run main function
main "$@"
