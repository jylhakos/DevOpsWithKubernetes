#!/bin/bash

# GKE Deployment Setup Script
# This script installs necessary tools and sets up the environment for GKE deployment

set -e

echo "🚀 Starting GKE deployment setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    print_error "This script is designed for Linux systems"
    exit 1
fi

# Update system packages
print_status "Updating system packages..."
sudo apt-get update

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    print_status "Installing Docker..."
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    print_status "Docker installed successfully"
else
    print_status "Docker is already installed"
fi

# Install Google Cloud SDK
if ! command -v gcloud &> /dev/null; then
    print_status "Installing Google Cloud SDK..."
    curl https://sdk.cloud.google.com | bash
    exec -l $SHELL
    print_status "Google Cloud SDK installed successfully"
else
    print_status "Google Cloud SDK is already installed"
fi

# Install kubectl
if ! command -v kubectl &> /dev/null; then
    print_status "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    print_status "kubectl installed successfully"
else
    print_status "kubectl is already installed"
fi

# Install Helm
if ! command -v helm &> /dev/null; then
    print_status "Installing Helm..."
    curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
    sudo apt-get install apt-transport-https --yes
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm
    print_status "Helm installed successfully"
else
    print_status "Helm is already installed"
fi

# Verify installations
print_status "Verifying installations..."
docker --version
gcloud version
kubectl version --client
helm version

print_status "✅ Setup completed successfully!"
print_warning "Please run 'newgrp docker' or logout and login again to use Docker without sudo"
print_warning "Run 'gcloud auth login' to authenticate with Google Cloud"
print_warning "Run 'gcloud config set project YOUR_PROJECT_ID' to set your GCP project"

echo ""
print_status "Next steps:"
echo "1. Run: gcloud auth login"
echo "2. Run: gcloud config set project YOUR_PROJECT_ID"
echo "3. Run: gcloud container clusters get-credentials YOUR_CLUSTER_NAME --zone YOUR_ZONE"
echo "4. Update the deployment scripts with your project details"
echo "5. Run: ./deploy.sh"
