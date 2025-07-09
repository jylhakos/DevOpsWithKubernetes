#!/bin/bash

# Local Environment Setup Script
# This script installs and configures the required tools for GKE deployment

set -e

echo "🔧 Setting up local environment for GKE deployment..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Docker if not present
if ! command_exists docker; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker installed. Please log out and log back in to use Docker without sudo."
else
    echo "✅ Docker already installed"
fi

# Install Google Cloud SDK
if ! command_exists gcloud; then
    echo "☁️  Installing Google Cloud SDK..."
    curl https://sdk.cloud.google.com | bash
    exec -l $SHELL
    echo "✅ Google Cloud SDK installed"
else
    echo "✅ Google Cloud SDK already installed"
fi

# Install kubectl
if ! command_exists kubectl; then
    echo "☸️  Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    echo "✅ kubectl installed"
else
    echo "✅ kubectl already installed"
fi

# Install Helm (package manager for Kubernetes)
if ! command_exists helm; then
    echo "⚓ Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    echo "✅ Helm installed"
else
    echo "✅ Helm already installed"
fi

echo ""
echo "🎉 Local environment setup complete!"
echo ""
echo "Next steps:"
echo "1. Authenticate with Google Cloud: gcloud auth login"
echo "2. Set your default project: gcloud config set project YOUR_PROJECT_ID"
echo "3. Run the cluster setup script: ./scripts/setup-gke-cluster.sh"
echo "4. Deploy your application: ./scripts/deploy-to-gke.sh"
echo ""
echo "Tool versions:"
docker --version 2>/dev/null || echo "Docker: Not available (restart terminal)"
gcloud --version 2>/dev/null || echo "gcloud: Not available (restart terminal)"
kubectl version --client 2>/dev/null || echo "kubectl: Not available"
helm version --short 2>/dev/null || echo "Helm: Not available"
