#!/bin/bash

# GKE Cluster Setup Script
# This script creates a new GKE cluster for the React frontend

set -e

# Configuration
PROJECT_ID=${1:-"your-gcp-project-id"}
CLUSTER_NAME=${2:-"react-frontend-cluster"}
REGION=${3:-"us-central1-a"}
NODE_COUNT=${4:-3}
MACHINE_TYPE=${5:-"e2-medium"}

echo "🏗️  Creating GKE cluster..."
echo "Project ID: $PROJECT_ID"
echo "Cluster: $CLUSTER_NAME"
echo "Region: $REGION"
echo "Node Count: $NODE_COUNT"
echo "Machine Type: $MACHINE_TYPE"

# Check if gcloud is installed
command -v gcloud >/dev/null 2>&1 || { echo "❌ gcloud CLI is required but not installed. Aborting." >&2; exit 1; }

# Set the project
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "🔧 Enabling required APIs..."
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com

# Create GKE cluster
echo "☸️  Creating GKE cluster (this may take several minutes)..."
gcloud container clusters create $CLUSTER_NAME \
    --zone=$REGION \
    --num-nodes=$NODE_COUNT \
    --machine-type=$MACHINE_TYPE \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=10 \
    --enable-autorepair \
    --enable-autoupgrade \
    --disk-size=32GB \
    --disk-type=pd-standard \
    --image-type=COS_CONTAINERD \
    --enable-ip-alias \
    --network=default \
    --subnetwork=default \
    --enable-cloud-logging \
    --enable-cloud-monitoring

# Get cluster credentials
echo "🔑 Getting cluster credentials..."
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$REGION

echo "✅ GKE cluster created successfully!"
echo ""
echo "Cluster information:"
kubectl cluster-info
echo ""
echo "Nodes:"
kubectl get nodes
echo ""
echo "To delete this cluster later, run:"
echo "gcloud container clusters delete $CLUSTER_NAME --zone=$REGION"
