#!/bin/bash

# Script to deploy application to EKS
# Usage: ./deploy-to-eks.sh [namespace]

set -e

NAMESPACE=${1:-"typescript-app"}

echo "Deploying TypeScript application to EKS cluster..."

# Create namespace and apply resource limits
echo "Creating namespace and applying resource limits..."
kubectl apply -f ../k8s/namespace-resources.yaml

# Apply network policies
echo "Applying network policies..."
kubectl apply -f ../k8s/network-policy.yaml

# Deploy backend
echo "Deploying backend..."
kubectl apply -f ../k8s/backend-deployment.yaml -n $NAMESPACE

# Deploy frontend
echo "Deploying frontend..."
kubectl apply -f ../k8s/frontend-deployment.yaml -n $NAMESPACE

# Apply horizontal pod autoscaler
echo "Applying horizontal pod autoscaler..."
kubectl apply -f ../k8s/hpa.yaml -n $NAMESPACE

# Wait for deployments to be ready
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/backend-deployment -n $NAMESPACE
kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment -n $NAMESPACE

# Get service information
echo "Getting service information..."
kubectl get services -n $NAMESPACE

echo ""
echo "Deployment completed successfully!"
echo ""
echo "To get the frontend URL, run:"
echo "kubectl get service frontend-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
echo ""
echo "To check pod status, run:"
echo "kubectl get pods -n $NAMESPACE"
echo ""
echo "To check logs, run:"
echo "kubectl logs -f deployment/backend-deployment -n $NAMESPACE"
echo "kubectl logs -f deployment/frontend-deployment -n $NAMESPACE"
