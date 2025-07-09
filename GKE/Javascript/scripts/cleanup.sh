#!/bin/bash

# Cleanup script for GKE resources
# This script removes all created GKE resources

set -e

PROJECT_ID=${1:-"your-gcp-project-id"}
CLUSTER_NAME=${2:-"react-frontend-cluster"}
REGION=${3:-"us-central1-a"}

echo "🧹 Cleaning up GKE resources..."
echo "Project ID: $PROJECT_ID"
echo "Cluster: $CLUSTER_NAME"
echo "Region: $REGION"

# Set the project
gcloud config set project $PROJECT_ID

# Get cluster credentials
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$REGION 2>/dev/null || echo "Cluster not found or already deleted"

# Delete Kubernetes resources
echo "🗑️  Deleting Kubernetes resources..."
kubectl delete -f k8s/ --ignore-not-found=true

# Delete the cluster
echo "🗑️  Deleting GKE cluster..."
gcloud container clusters delete $CLUSTER_NAME --zone=$REGION --quiet

# Delete container images (optional)
read -p "Do you want to delete container images from Container Registry? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Deleting container images..."
    gcloud container images delete gcr.io/$PROJECT_ID/react-frontend --force-delete-tags --quiet || echo "No images found"
fi

echo "✅ Cleanup completed!"
