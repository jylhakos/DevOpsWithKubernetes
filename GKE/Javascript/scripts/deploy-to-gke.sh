#!/bin/bash

# React Frontend GKE Deployment Script
# This script builds and deploys the React frontend to Google Kubernetes Engine

set -e

# Configuration
PROJECT_ID=${1:-"your-gcp-project-id"}
CLUSTER_NAME=${2:-"react-frontend-cluster"}
REGION=${3:-"us-central1-a"}
IMAGE_NAME="react-frontend"
IMAGE_TAG=${4:-"latest"}

echo "🚀 Starting deployment to GKE..."
echo "Project ID: $PROJECT_ID"
echo "Cluster: $CLUSTER_NAME"
echo "Region: $REGION"
echo "Image: $IMAGE_NAME:$IMAGE_TAG"

# Check if required tools are installed
command -v gcloud >/dev/null 2>&1 || { echo "❌ gcloud CLI is required but not installed. Aborting." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed. Aborting." >&2; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required but not installed. Aborting." >&2; exit 1; }

# Set the project
echo "📋 Setting GCP project..."
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "🔧 Enabling required GCP APIs..."
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Build Docker image
echo "🐳 Building Docker image..."
docker build -t gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG .

# Push to Google Container Registry
echo "📤 Pushing image to Google Container Registry..."
docker push gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG

# Get GKE credentials
echo "🔑 Getting GKE cluster credentials..."
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$REGION

# Update deployment YAML with correct project ID
echo "📝 Updating deployment configuration..."
sed -i "s/PROJECT_ID/$PROJECT_ID/g" k8s/deployment.yaml

# Apply Kubernetes configurations
echo "☸️  Applying Kubernetes configurations..."
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml

# Optional: Apply SSL certificate and ingress (uncomment if using custom domain)
# kubectl apply -f k8s/ssl-certificate.yaml
# kubectl apply -f k8s/ingress.yaml

# Wait for deployment to be ready
echo "⏳ Waiting for deployment to be ready..."
kubectl rollout status deployment/react-frontend-deployment

# Get service information
echo "🌐 Getting service information..."
kubectl get services react-frontend-service

echo "✅ Deployment completed successfully!"
echo ""
echo "To get the external IP address, run:"
echo "kubectl get service react-frontend-service"
echo ""
echo "To view logs:"
echo "kubectl logs -l app=react-frontend"
echo ""
echo "To scale the deployment:"
echo "kubectl scale deployment react-frontend-deployment --replicas=5"
