#!/bin/bash

# Configuration
PROJECT_ID=${PROJECT_ID:-"your-gcp-project-id"}
CLUSTER_NAME=${CLUSTER_NAME:-"typescript-cluster"}
ZONE=${ZONE:-"us-central1-a"}
REGION=${REGION:-"us-central1"}

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

# Create GKE cluster
create_cluster() {
    print_status "Creating GKE cluster: $CLUSTER_NAME"
    
    gcloud container clusters create $CLUSTER_NAME \
        --project=$PROJECT_ID \
        --zone=$ZONE \
        --machine-type=e2-medium \
        --num-nodes=3 \
        --enable-autorepair \
        --enable-autoupgrade \
        --enable-autoscaling \
        --min-nodes=1 \
        --max-nodes=10 \
        --enable-network-policy \
        --enable-ip-alias \
        --enable-shielded-nodes \
        --shielded-secure-boot \
        --shielded-integrity-monitoring \
        --enable-autorepair \
        --enable-autoupgrade \
        --maintenance-window-start="2023-01-01T09:00:00Z" \
        --maintenance-window-end="2023-01-01T17:00:00Z" \
        --maintenance-window-recurrence="FREQ=WEEKLY;BYDAY=SA,SU"
    
    if [ $? -eq 0 ]; then
        print_status "GKE cluster created successfully."
    else
        print_error "Failed to create GKE cluster."
        exit 1
    fi
}

# Get cluster credentials
get_credentials() {
    print_status "Getting cluster credentials..."
    
    gcloud container clusters get-credentials $CLUSTER_NAME \
        --zone=$ZONE \
        --project=$PROJECT_ID
    
    if [ $? -eq 0 ]; then
        print_status "Cluster credentials retrieved successfully."
    else
        print_error "Failed to get cluster credentials."
        exit 1
    fi
}

# Enable required APIs
enable_apis() {
    print_status "Enabling required Google Cloud APIs..."
    
    gcloud services enable container.googleapis.com \
        containerregistry.googleapis.com \
        cloudbuild.googleapis.com \
        monitoring.googleapis.com \
        logging.googleapis.com \
        --project=$PROJECT_ID
    
    if [ $? -eq 0 ]; then
        print_status "APIs enabled successfully."
    else
        print_error "Failed to enable APIs."
        exit 1
    fi
}

# Configure Docker for GCR
configure_docker() {
    print_status "Configuring Docker for Google Container Registry..."
    
    gcloud auth configure-docker --quiet
    
    if [ $? -eq 0 ]; then
        print_status "Docker configured for GCR successfully."
    else
        print_error "Failed to configure Docker for GCR."
        exit 1
    fi
}

# Main function
main() {
    check_project_id
    enable_apis
    configure_docker
    create_cluster
    get_credentials
    
    print_status "GKE setup completed successfully!"
    print_status "Cluster name: $CLUSTER_NAME"
    print_status "Zone: $ZONE"
    print_status "Project ID: $PROJECT_ID"
    print_warning "You can now deploy your applications using the deploy script."
}

# Run main function
main
