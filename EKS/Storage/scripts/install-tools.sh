#!/bin/bash

# Install Required Tools for EKS Deployment
# This script installs all necessary tools on a Linux system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing required tools for EKS deployment...${NC}"

# Update system
echo -e "${YELLOW}Updating system packages...${NC}"
sudo apt-get update

# Install curl, unzip, and other utilities
echo -e "${YELLOW}Installing basic utilities...${NC}"
sudo apt-get install -y curl unzip wget gnupg2 software-properties-common apt-transport-https ca-certificates

# Install Docker
echo -e "${YELLOW}Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    echo -e "${GREEN}Docker installed successfully${NC}"
else
    echo -e "${GREEN}Docker is already installed${NC}"
fi

# Install AWS CLI v2
echo -e "${YELLOW}Installing AWS CLI v2...${NC}"
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws/
    echo -e "${GREEN}AWS CLI v2 installed successfully${NC}"
else
    echo -e "${GREEN}AWS CLI is already installed${NC}"
fi

# Install kubectl
echo -e "${YELLOW}Installing kubectl...${NC}"
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    echo -e "${GREEN}kubectl installed successfully${NC}"
else
    echo -e "${GREEN}kubectl is already installed${NC}"
fi

# Install eksctl
echo -e "${YELLOW}Installing eksctl...${NC}"
if ! command -v eksctl &> /dev/null; then
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
    echo -e "${GREEN}eksctl installed successfully${NC}"
else
    echo -e "${GREEN}eksctl is already installed${NC}"
fi

# Install Helm
echo -e "${YELLOW}Installing Helm...${NC}"
if ! command -v helm &> /dev/null; then
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install -y helm
    echo -e "${GREEN}Helm installed successfully${NC}"
else
    echo -e "${GREEN}Helm is already installed${NC}"
fi

# Install git (if not already installed)
echo -e "${YELLOW}Installing git...${NC}"
if ! command -v git &> /dev/null; then
    sudo apt-get install -y git
    echo -e "${GREEN}Git installed successfully${NC}"
else
    echo -e "${GREEN}Git is already installed${NC}"
fi

# Install jq for JSON processing
echo -e "${YELLOW}Installing jq...${NC}"
if ! command -v jq &> /dev/null; then
    sudo apt-get install -y jq
    echo -e "${GREEN}jq installed successfully${NC}"
else
    echo -e "${GREEN}jq is already installed${NC}"
fi

# Make scripts executable
echo -e "${YELLOW}Making scripts executable...${NC}"
chmod +x scripts/*.sh

echo -e "${GREEN}All tools installed successfully!${NC}"
echo ""
echo -e "${YELLOW}Installed versions:${NC}"
echo "Docker: $(docker --version)"
echo "AWS CLI: $(aws --version)"
echo "kubectl: $(kubectl version --client --short)"
echo "eksctl: $(eksctl version)"
echo "Helm: $(helm version --short)"
echo "Git: $(git --version)"
echo "jq: $(jq --version)"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Log out and log back in to apply Docker group membership"
echo "2. Configure AWS credentials: aws configure"
echo "3. Run ./scripts/setup-cluster.sh to create the EKS cluster"
echo ""
echo -e "${RED}Important: You need to restart your shell or log out/in for Docker group changes to take effect${NC}"
