#!/bin/bash

# Cleanup script for GKE deployment
# This script removes all resources created during deployment

set -e

# Configuration - Update these values to match your deployment
PROJECT_ID="your-gcp-project-id"
CLUSTER_NAME="myapp-cluster"
ZONE="us-central1-a"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to delete Kubernetes resources
cleanup_k8s_resources() {
    print_status "Cleaning up Kubernetes resources..."
    
    if kubectl get namespace myapp-namespace &> /dev/null; then
        kubectl delete namespace myapp-namespace --ignore-not-found=true
        print_status "Namespace deleted"
    else
        print_status "Namespace doesn't exist"
    fi
}

# Function to delete static IP addresses
cleanup_static_ips() {
    print_status "Cleaning up static IP addresses..."
    
    gcloud compute addresses delete backend-ip --global --quiet || print_warning "Backend IP not found"
    gcloud compute addresses delete frontend-ip --global --quiet || print_warning "Frontend IP not found"
}

# Function to delete Docker images
cleanup_images() {
    print_status "Cleaning up Docker images..."
    
    # Delete from Container Registry
    gcloud container images delete gcr.io/$PROJECT_ID/backend:latest --quiet || print_warning "Backend image not found"
    gcloud container images delete gcr.io/$PROJECT_ID/frontend:latest --quiet || print_warning "Frontend image not found"
    
    # Delete local images
    docker rmi gcr.io/$PROJECT_ID/backend:latest || print_warning "Local backend image not found"
    docker rmi gcr.io/$PROJECT_ID/frontend:latest || print_warning "Local frontend image not found"
}

# Function to delete GKE cluster
cleanup_cluster() {
    print_warning "This will delete the entire GKE cluster. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Deleting GKE cluster..."
        gcloud container clusters delete $CLUSTER_NAME --zone=$ZONE --quiet
        print_status "Cluster deleted"
    else
        print_status "Cluster deletion skipped"
    fi
}

# Main cleanup function
main() {
    print_warning "🧹 Starting cleanup process..."
    
    if [ "$PROJECT_ID" = "your-gcp-project-id" ]; then
        print_error "Please update the PROJECT_ID in this script before running"
        exit 1
    fi
    
    # Set project
    gcloud config set project $PROJECT_ID
    
    # Get cluster credentials if cluster exists
    if gcloud container clusters describe $CLUSTER_NAME --zone=$ZONE &> /dev/null; then
        gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE
    fi
    
    cleanup_k8s_resources
    cleanup_static_ips
    cleanup_images
    cleanup_cluster
    
    print_status "✅ Cleanup completed!"
}

main "$@"
