#!/bin/bash

# AWS EKS Tools Installation Script for Ubuntu/Debian
# This script installs all necessary tools for EKS deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Update system packages
update_system() {
    echo_info "Updating system packages..."
    sudo apt-get update -y
    sudo apt-get upgrade -y
}

# Install basic dependencies
install_dependencies() {
    echo_info "Installing basic dependencies..."
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        unzip \
        wget \
        git \
        build-essential
}

# Install Docker
install_docker() {
    echo_info "Installing Docker..."
    
    if command -v docker &> /dev/null; then
        echo_info "Docker is already installed."
        return
    fi
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    
    # Start and enable Docker
    sudo systemctl start docker
    sudo systemctl enable docker
    
    echo_info "Docker installed successfully. Please log out and log back in for group changes to take effect."
}

# Install Docker Compose
install_docker_compose() {
    echo_info "Installing Docker Compose..."
    
    if command -v docker-compose &> /dev/null; then
        echo_info "Docker Compose is already installed."
        return
    fi
    
    # Download and install Docker Compose
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    echo_info "Docker Compose installed successfully."
}

# Install AWS CLI v2
install_aws_cli() {
    echo_info "Installing AWS CLI v2..."
    
    if command -v aws &> /dev/null; then
        echo_info "AWS CLI is already installed."
        return
    fi
    
    # Download and install AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws/
    
    echo_info "AWS CLI v2 installed successfully."
}

# Install kubectl
install_kubectl() {
    echo_info "Installing kubectl..."
    
    if command -v kubectl &> /dev/null; then
        echo_info "kubectl is already installed."
        return
    fi
    
    # Download kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    
    # Install kubectl
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    
    echo_info "kubectl installed successfully."
}

# Install eksctl
install_eksctl() {
    echo_info "Installing eksctl..."
    
    if command -v eksctl &> /dev/null; then
        echo_info "eksctl is already installed."
        return
    fi
    
    # Download and install eksctl
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
    
    echo_info "eksctl installed successfully."
}

# Install Helm
install_helm() {
    echo_info "Installing Helm..."
    
    if command -v helm &> /dev/null; then
        echo_info "Helm is already installed."
        return
    fi
    
    # Download and install Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    
    echo_info "Helm installed successfully."
}

# Install Node.js and npm
install_nodejs() {
    echo_info "Installing Node.js and npm..."
    
    if command -v node &> /dev/null; then
        echo_info "Node.js is already installed."
        return
    fi
    
    # Install Node.js 16.x
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    echo_info "Node.js and npm installed successfully."
}

# Generate SSH key if not exists
generate_ssh_key() {
    echo_info "Checking SSH key..."
    
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo_info "Generating SSH key..."
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
        echo_info "SSH key generated at ~/.ssh/id_rsa"
    else
        echo_info "SSH key already exists."
    fi
}

# Verify installations
verify_installations() {
    echo_info "Verifying installations..."
    
    # Check versions
    echo "Docker version:"
    docker --version || echo_error "Docker not found"
    
    echo "Docker Compose version:"
    docker-compose --version || echo_error "Docker Compose not found"
    
    echo "AWS CLI version:"
    aws --version || echo_error "AWS CLI not found"
    
    echo "kubectl version:"
    kubectl version --client || echo_error "kubectl not found"
    
    echo "eksctl version:"
    eksctl version || echo_error "eksctl not found"
    
    echo "Helm version:"
    helm version || echo_error "Helm not found"
    
    echo "Node.js version:"
    node --version || echo_error "Node.js not found"
    
    echo "npm version:"
    npm --version || echo_error "npm not found"
}

# Configure AWS CLI
configure_aws() {
    echo_info "AWS CLI configuration..."
    echo_warn "Please run 'aws configure' to set up your AWS credentials after installation."
    echo_warn "You'll need:"
    echo_warn "  - AWS Access Key ID"
    echo_warn "  - AWS Secret Access Key"
    echo_warn "  - Default region (e.g., us-east-1)"
    echo_warn "  - Default output format (json)"
}

# Main installation process
main() {
    echo_info "Starting AWS EKS tools installation..."
    
    update_system
    install_dependencies
    install_docker
    install_docker_compose
    install_aws_cli
    install_kubectl
    install_eksctl
    install_helm
    install_nodejs
    generate_ssh_key
    
    echo_info "Installation completed!"
    
    verify_installations
    configure_aws
    
    echo_info "Please log out and log back in for Docker group changes to take effect."
    echo_info "Don't forget to run 'aws configure' to set up your AWS credentials."
}

# Run main function
main
