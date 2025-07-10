#!/bin/bash

# Deploy Applications to EKS
# This script deploys all applications to the EKS cluster

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Deploying applications to EKS...${NC}"

# Deploy in order (databases first, then applications)
echo -e "${YELLOW}Deploying PostgreSQL...${NC}"
kubectl apply -f k8s/deployments/postgres-deployment.yaml
kubectl apply -f k8s/services/services.yaml

echo -e "${YELLOW}Waiting for PostgreSQL to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/postgres-deployment

echo -e "${YELLOW}Deploying Redis...${NC}"
kubectl apply -f k8s/deployments/redis-deployment.yaml

echo -e "${YELLOW}Waiting for Redis to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/redis-deployment

echo -e "${YELLOW}Deploying Backend...${NC}"
kubectl apply -f k8s/deployments/backend-deployment.yaml

echo -e "${YELLOW}Waiting for Backend to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/backend-deployment

echo -e "${YELLOW}Deploying Frontend...${NC}"
kubectl apply -f k8s/deployments/frontend-deployment.yaml

echo -e "${YELLOW}Waiting for Frontend to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment

echo -e "${YELLOW}Setting up Ingress and Load Balancer...${NC}"
kubectl apply -f k8s/ingress/ingress.yaml

echo -e "${GREEN}All applications deployed successfully!${NC}"
echo ""
echo -e "${YELLOW}Checking deployment status:${NC}"
kubectl get pods
echo ""
kubectl get services
echo ""
kubectl get ingress

echo ""
echo -e "${YELLOW}Getting Load Balancer URL:${NC}"
kubectl get ingress app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
echo ""
echo ""
echo -e "${YELLOW}To check logs:${NC}"
echo "Backend: kubectl logs -l app=backend -f"
echo "Frontend: kubectl logs -l app=frontend -f"
echo "PostgreSQL: kubectl logs -l app=postgres -f"
echo "Redis: kubectl logs -l app=redis -f"
echo ""
echo -e "${YELLOW}To access applications:${NC}"
echo "Frontend: https://your-domain.com"
echo "Backend API: https://api.your-domain.com/ping"
echo "Backend with Redis check: https://api.your-domain.com/ping?redis=true"
