#!/bin/bash

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

# Check if required tools are installed
check_requirements() {
    print_status "Checking requirements..."
    
    if ! command -v gcloud &> /dev/null; then
        print_error "gcloud CLI is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install it first."
        exit 1
    fi
    
    print_status "All requirements are met."
}

# Install Google Cloud CLI
install_gcloud() {
    print_status "Installing Google Cloud CLI..."
    
    if command -v gcloud &> /dev/null; then
        print_warning "Google Cloud CLI is already installed."
        return 0
    fi
    
    # Download and install Google Cloud CLI
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-458.0.1-linux-x86_64.tar.gz
    tar -xf google-cloud-cli-458.0.1-linux-x86_64.tar.gz
    ./google-cloud-sdk/install.sh --quiet
    
    # Add to PATH
    echo 'export PATH=$PATH:$HOME/google-cloud-sdk/bin' >> ~/.bashrc
    source ~/.bashrc
    
    print_status "Google Cloud CLI installed successfully."
}

# Install kubectl
install_kubectl() {
    print_status "Installing kubectl..."
    
    if command -v kubectl &> /dev/null; then
        print_warning "kubectl is already installed."
        return 0
    fi
    
    # Download kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    
    print_status "kubectl installed successfully."
}

# Install Docker
install_docker() {
    print_status "Installing Docker..."
    
    if command -v docker &> /dev/null; then
        print_warning "Docker is already installed."
        return 0
    fi
    
    # Update package index
    sudo apt-get update
    
    # Install dependencies
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package index again
    sudo apt-get update
    
    # Install Docker
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    
    print_status "Docker installed successfully. Please log out and log back in for group changes to take effect."
}

# Main installation function
main() {
    print_status "Starting tool installation..."
    
    install_gcloud
    install_kubectl
    install_docker
    
    print_status "Tool installation completed!"
    print_warning "Please run 'gcloud auth login' and 'gcloud auth configure-docker' to authenticate with Google Cloud."
    print_warning "Also run 'newgrp docker' or log out and log back in to use Docker without sudo."
}

# Run main function
main
