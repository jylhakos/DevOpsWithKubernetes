#!/bin/bash

# Deployment Verification Script
# This script checks if the deployment is successful

set -e

echo "🔍 Verifying GKE deployment..."

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ kubectl is not configured or cluster is not accessible"
    exit 1
fi

echo "✅ Cluster connection verified"

# Check deployment status
if kubectl get deployment react-frontend-deployment &> /dev/null; then
    echo "✅ Deployment exists"
    kubectl get deployment react-frontend-deployment
    
    # Check if deployment is ready
    if kubectl rollout status deployment/react-frontend-deployment --timeout=300s; then
        echo "✅ Deployment is ready"
    else
        echo "❌ Deployment is not ready"
        exit 1
    fi
else
    echo "❌ Deployment not found"
    exit 1
fi

# Check service status
if kubectl get service react-frontend-service &> /dev/null; then
    echo "✅ Service exists"
    kubectl get service react-frontend-service
    
    # Get external IP
    EXTERNAL_IP=$(kubectl get service react-frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [ -n "$EXTERNAL_IP" ]; then
        echo "✅ External IP assigned: $EXTERNAL_IP"
        echo "🌐 Application should be accessible at: http://$EXTERNAL_IP"
    else
        echo "⏳ External IP not yet assigned (this may take a few minutes)"
    fi
else
    echo "❌ Service not found"
    exit 1
fi

# Check pods
echo ""
echo "📊 Pod status:"
kubectl get pods -l app=react-frontend

# Check HPA
if kubectl get hpa react-frontend-hpa &> /dev/null; then
    echo ""
    echo "📈 Horizontal Pod Autoscaler:"
    kubectl get hpa react-frontend-hpa
fi

echo ""
echo "🎉 Deployment verification completed!"
