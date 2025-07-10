#!/bin/bash

# Script to create EKS cluster
# Usage: ./create-eks-cluster.sh <cluster-name> <region>

set -e

CLUSTER_NAME=${1:-"typescript-app-cluster"}
REGION=${2:-"us-west-2"}
NODE_TYPE=${3:-"t3.medium"}
MIN_NODES=${4:-"2"}
MAX_NODES=${5:-"10"}

echo "Creating EKS cluster: $CLUSTER_NAME in region: $REGION"

# Create EKS cluster with managed node group
eksctl create cluster \
  --name=$CLUSTER_NAME \
  --region=$REGION \
  --version=1.27 \
  --nodegroup-name=workers \
  --node-type=$NODE_TYPE \
  --nodes=$MIN_NODES \
  --nodes-min=$MIN_NODES \
  --nodes-max=$MAX_NODES \
  --ssh-access \
  --ssh-public-key=~/.ssh/id_rsa.pub \
  --managed \
  --enable-ssm

echo "Cluster creation initiated. This may take 15-20 minutes..."

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
eksctl utils wait-for-cluster --name=$CLUSTER_NAME --region=$REGION

# Update kubeconfig
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Verify cluster
kubectl get nodes

echo "EKS cluster '$CLUSTER_NAME' created successfully!"
echo "Cluster endpoint: $(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query 'cluster.endpoint' --output text)"
echo "To delete the cluster later, run: eksctl delete cluster --name=$CLUSTER_NAME --region=$REGION"
