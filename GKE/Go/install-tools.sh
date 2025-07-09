#!/bin/bash

# Install required tools for GKE deployment on Ubuntu/Debian Linux
# This script installs Docker, Google Cloud SDK, and kubectl

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${YELLOW}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Install Docker
install_docker() {
    print_status "Installing Docker..."
    
    if command -v docker &> /dev/null; then
        print_success "Docker is already installed"
        return
    fi
    
    # Update package index
    sudo apt-get update
    
    # Install packages to allow apt to use a repository over HTTPS
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Set up the repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package index
    sudo apt-get update
    
    # Install Docker Engine
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    print_success "Docker installed successfully"
    print_status "Please log out and log back in to use Docker without sudo"
}

# Install Google Cloud SDK
install_gcloud() {
    print_status "Installing Google Cloud SDK..."
    
    if command -v gcloud &> /dev/null; then
        print_success "Google Cloud SDK is already installed"
        return
    fi
    
    # Add the Cloud SDK distribution URI as a package source
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    
    # Import the Google Cloud public key
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    
    # Update and install the Cloud SDK
    sudo apt-get update && sudo apt-get install -y google-cloud-cli
    
    # Install additional components
    sudo apt-get install -y google-cloud-sdk-gke-gcloud-auth-plugin
    
    print_success "Google Cloud SDK installed successfully"
    print_status "Run 'gcloud init' to initialize the SDK"
}

# Install kubectl
install_kubectl() {
    print_status "Installing kubectl..."
    
    if command -v kubectl &> /dev/null; then
        print_success "kubectl is already installed"
        return
    fi
    
    # Download the latest release
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    
    # Install kubectl
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    
    # Clean up
    rm kubectl
    
    print_success "kubectl installed successfully"
}

# Install Helm (optional but recommended)
install_helm() {
    print_status "Installing Helm..."
    
    if command -v helm &> /dev/null; then
        print_success "Helm is already installed"
        return
    fi
    
    # Download and install Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    
    print_success "Helm installed successfully"
}

# Verify installations
verify_installations() {
    print_status "Verifying installations..."
    
    echo "Docker version:"
    docker --version || print_error "Docker not found"
    
    echo "Google Cloud SDK version:"
    gcloud --version || print_error "gcloud not found"
    
    echo "kubectl version:"
    kubectl version --client || print_error "kubectl not found"
    
    echo "Helm version:"
    helm version || print_error "Helm not found"
    
    print_success "All tools verified"
}

# Main execution
main() {
    echo -e "${GREEN}🛠️  Installing GKE Deployment Tools${NC}"
    echo ""
    
    # Update system
    print_status "Updating system packages..."
    sudo apt-get update
    
    install_docker
    install_gcloud
    install_kubectl
    install_helm
    verify_installations
    
    echo ""
    print_success "🎉 Installation completed successfully!"
    echo -e "${YELLOW}📝 Next steps:${NC}"
    echo "1. Log out and log back in to use Docker without sudo"
    echo "2. Run 'gcloud init' to initialize Google Cloud SDK"
    echo "3. Run 'gcloud auth login' to authenticate with Google Cloud"
    echo "4. Set your project: gcloud config set project YOUR_PROJECT_ID"
    echo "5. Enable required APIs:"
    echo "   - gcloud services enable container.googleapis.com"
    echo "   - gcloud services enable containerregistry.googleapis.com"
}

# Run main function
main "$@"
