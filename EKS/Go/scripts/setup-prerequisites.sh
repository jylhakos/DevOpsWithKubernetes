#!/bin/bash

# Setup script for EKS deployment prerequisites
# This script installs all necessary tools on Ubuntu/Debian Linux

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up prerequisites for EKS deployment...${NC}"

# Update package list
update_packages() {
    echo -e "${YELLOW}Updating package list...${NC}"
    sudo apt-get update
}

# Install Docker
install_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${YELLOW}Installing Docker...${NC}"
        
        # Remove old versions
        sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
        
        # Install dependencies
        sudo apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg \
            lsb-release
        
        # Add Docker's official GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        
        # Set up the stable repository
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Install Docker Engine
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        
        # Add user to docker group
        sudo usermod -aG docker $USER
        
        # Start and enable Docker
        sudo systemctl start docker
        sudo systemctl enable docker
        
        echo -e "${GREEN}Docker installed successfully!${NC}"
    else
        echo -e "${GREEN}Docker is already installed!${NC}"
    fi
}

# Install AWS CLI v2
install_aws_cli() {
    if ! command -v aws >/dev/null 2>&1; then
        echo -e "${YELLOW}Installing AWS CLI v2...${NC}"
        
        # Download and install AWS CLI v2
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        
        # Clean up
        rm -rf awscliv2.zip aws/
        
        echo -e "${GREEN}AWS CLI v2 installed successfully!${NC}"
    else
        echo -e "${GREEN}AWS CLI is already installed!${NC}"
    fi
}

# Install kubectl
install_kubectl() {
    if ! command -v kubectl >/dev/null 2>&1; then
        echo -e "${YELLOW}Installing kubectl...${NC}"
        
        # Download kubectl
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        
        # Install kubectl
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        
        # Clean up
        rm kubectl
        
        echo -e "${GREEN}kubectl installed successfully!${NC}"
    else
        echo -e "${GREEN}kubectl is already installed!${NC}"
    fi
}

# Install eksctl
install_eksctl() {
    if ! command -v eksctl >/dev/null 2>&1; then
        echo -e "${YELLOW}Installing eksctl...${NC}"
        
        # Download and extract eksctl
        curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
        
        # Move to bin directory
        sudo mv /tmp/eksctl /usr/local/bin
        
        echo -e "${GREEN}eksctl installed successfully!${NC}"
    else
        echo -e "${GREEN}eksctl is already installed!${NC}"
    fi
}

# Install Helm (optional but recommended)
install_helm() {
    if ! command -v helm >/dev/null 2>&1; then
        echo -e "${YELLOW}Installing Helm...${NC}"
        
        # Download and install Helm
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        
        echo -e "${GREEN}Helm installed successfully!${NC}"
    else
        echo -e "${GREEN}Helm is already installed!${NC}"
    fi
}

# Verify installations
verify_installations() {
    echo -e "${YELLOW}Verifying installations...${NC}"
    
    echo "Docker version:"
    docker --version
    
    echo "AWS CLI version:"
    aws --version
    
    echo "kubectl version:"
    kubectl version --client
    
    echo "eksctl version:"
    eksctl version
    
    echo "Helm version:"
    helm version
    
    echo -e "${GREEN}All tools installed successfully!${NC}"
}

# Configure AWS credentials
configure_aws() {
    echo -e "${YELLOW}AWS Configuration:${NC}"
    echo "Please run 'aws configure' to set up your AWS credentials"
    echo "You'll need:"
    echo "- AWS Access Key ID"
    echo "- AWS Secret Access Key"
    echo "- Default region name (e.g., us-west-2)"
    echo "- Default output format (json)"
}

# Main execution
main() {
    update_packages
    install_docker
    install_aws_cli
    install_kubectl
    install_eksctl
    install_helm
    verify_installations
    configure_aws
    
    echo -e "${GREEN}Setup completed!${NC}"
    echo -e "${YELLOW}Please log out and log back in for Docker group changes to take effect.${NC}"
    echo -e "${YELLOW}Don't forget to run 'aws configure' to set up your AWS credentials.${NC}"
}

# Run the main function
main
