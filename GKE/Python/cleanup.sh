#!/bin/bash

# ML App GKE Cleanup Script
# This script removes the ML application from Google Kubernetes Engine

set -e

# Configuration
PROJECT_ID="${PROJECT_ID:-your-gcp-project-id}"
CLUSTER_NAME="${CLUSTER_NAME:-ml-app-cluster}"
ZONE="${ZONE:-us-central1-a}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

cleanup_kubernetes() {
    print_status "Cleaning up Kubernetes resources..."
    
    # Delete ingress first
    kubectl delete -f ./kubernetes/06-ingress.yaml --ignore-not-found=true
    
    # Delete services and deployments
    kubectl delete -f ./kubernetes/05-frontend.yaml --ignore-not-found=true
    kubectl delete -f ./kubernetes/04-backend.yaml --ignore-not-found=true
    
    # Delete job
    kubectl delete -f ./kubernetes/03-training-job.yaml --ignore-not-found=true
    
    # Delete configs and storage
    kubectl delete -f ./kubernetes/02-config.yaml --ignore-not-found=true
    kubectl delete -f ./kubernetes/01-storage.yaml --ignore-not-found=true
    
    # Delete namespace (this will clean up everything)
    kubectl delete namespace ml-app --ignore-not-found=true
}

delete_cluster() {
    print_warning "This will delete the entire GKE cluster. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Deleting GKE cluster: $CLUSTER_NAME"
        gcloud container clusters delete $CLUSTER_NAME --zone=$ZONE --quiet
    else
        print_status "Cluster deletion cancelled."
    fi
}

main() {
    print_status "Starting cleanup of ML App from GKE..."
    
    cleanup_kubernetes
    
    echo
    print_warning "Do you want to delete the entire GKE cluster as well? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        delete_cluster
    fi
    
    print_status "Cleanup completed!"
}

main "$@"
