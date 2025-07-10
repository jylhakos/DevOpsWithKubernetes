#!/bin/bash

# Quick Start Deployment Script
# This script orchestrates the entire deployment process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="app-cluster"
REGION="us-west-2"

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  EKS Deployment Quick Start Script     ${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait for user input
wait_for_user() {
    echo -e "${YELLOW}Press Enter to continue or Ctrl+C to exit...${NC}"
    read -r
}

# Check if tools are installed
echo -e "${BLUE}Step 1: Checking required tools...${NC}"
missing_tools=()

if ! command_exists docker; then missing_tools+=("docker"); fi
if ! command_exists aws; then missing_tools+=("aws"); fi
if ! command_exists kubectl; then missing_tools+=("kubectl"); fi
if ! command_exists eksctl; then missing_tools+=("eksctl"); fi
if ! command_exists helm; then missing_tools+=("helm"); fi

if [ ${#missing_tools[@]} -ne 0 ]; then
    echo -e "${RED}Missing tools: ${missing_tools[*]}${NC}"
    echo -e "${YELLOW}Run ./scripts/install-tools.sh to install missing tools${NC}"
    exit 1
fi

echo -e "${GREEN}All required tools are installed!${NC}"
echo ""

# Check AWS credentials
echo -e "${BLUE}Step 2: Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo -e "${RED}AWS credentials not configured!${NC}"
    echo -e "${YELLOW}Run 'aws configure' to set up your credentials${NC}"
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "${GREEN}AWS Account ID: ${AWS_ACCOUNT_ID}${NC}"
echo ""

# Confirm deployment
echo -e "${BLUE}Step 3: Deployment Configuration${NC}"
echo -e "${YELLOW}Cluster Name: ${CLUSTER_NAME}${NC}"
echo -e "${YELLOW}Region: ${REGION}${NC}"
echo -e "${YELLOW}Account ID: ${AWS_ACCOUNT_ID}${NC}"
echo ""
echo -e "${RED}This will create AWS resources that will incur charges.${NC}"
echo -e "${YELLOW}Do you want to proceed? (y/N)${NC}"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Deployment cancelled.${NC}"
    exit 0
fi

# Start deployment
echo -e "${GREEN}Starting deployment...${NC}"
echo ""

# Step 1: Create EKS Cluster
echo -e "${BLUE}Step 4: Creating EKS cluster...${NC}"
echo -e "${YELLOW}This may take 15-20 minutes...${NC}"
./scripts/setup-cluster.sh
echo ""

# Step 2: Build and Push Images
echo -e "${BLUE}Step 5: Building and pushing Docker images...${NC}"
./scripts/build-and-push.sh
echo ""

# Step 3: Deploy Applications
echo -e "${BLUE}Step 6: Deploying applications...${NC}"
./scripts/deploy-apps.sh
echo ""

# Step 4: Get deployment information
echo -e "${BLUE}Step 7: Getting deployment information...${NC}"
echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}         DEPLOYMENT COMPLETED!          ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# Get load balancer URL
echo -e "${YELLOW}Load Balancer URL:${NC}"
ALB_URL=$(kubectl get ingress app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "Not ready yet")
echo "http://${ALB_URL}"
echo ""

# Show service endpoints
echo -e "${YELLOW}Service Endpoints:${NC}"
echo "Frontend: http://${ALB_URL}/"
echo "Backend API: http://${ALB_URL}/ping"
echo "Backend with Redis: http://${ALB_URL}/ping?redis=true"
echo "Backend with PostgreSQL: http://${ALB_URL}/ping?postgres=true"
echo ""

# Show pod status
echo -e "${YELLOW}Pod Status:${NC}"
kubectl get pods -o wide
echo ""

# Show service status
echo -e "${YELLOW}Service Status:${NC}"
kubectl get services
echo ""

# Show useful commands
echo -e "${YELLOW}Useful Commands:${NC}"
echo "Check pods: kubectl get pods"
echo "Check services: kubectl get services"
echo "Check ingress: kubectl get ingress"
echo "View logs: kubectl logs -l app=backend -f"
echo "Scale apps: kubectl scale deployment backend-deployment --replicas=5"
echo ""

echo -e "${YELLOW}Monitoring:${NC}"
echo "Resource usage: kubectl top pods"
echo "Events: kubectl get events --sort-by='.lastTimestamp'"
echo "Describe pod: kubectl describe pod POD_NAME"
echo ""

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${YELLOW}Note: It may take a few minutes for the load balancer to be ready.${NC}"
echo ""

if [ "$ALB_URL" != "Not ready yet" ]; then
    echo -e "${YELLOW}Testing connectivity...${NC}"
    sleep 30  # Wait for ALB to be ready
    if curl -s -o /dev/null -w "%{http_code}" "http://${ALB_URL}/ping" | grep -q "200"; then
        echo -e "${GREEN}✓ Backend is responding!${NC}"
    else
        echo -e "${YELLOW}⚠ Backend might still be starting up. Try again in a few minutes.${NC}"
    fi
fi

echo ""
echo -e "${RED}Remember to run ./scripts/cleanup.sh when you're done to avoid charges!${NC}"
