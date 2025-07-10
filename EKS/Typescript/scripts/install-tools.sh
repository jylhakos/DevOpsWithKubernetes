#!/bin/bash

# Script to install all necessary tools for EKS deployment
# Run this script with: chmod +x install-tools.sh && ./install-tools.sh

set -e

echo "Installing AWS CLI, kubectl, and eksctl..."

# Check if running on Ubuntu/Debian
if [ -f /etc/debian_version ]; then
    # Update package list
    sudo apt-get update

    # Install AWS CLI v2
    echo "Installing AWS CLI v2..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws/

    # Install kubectl
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/

    # Install eksctl
    echo "Installing eksctl..."
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin

    # Install Docker (if not already installed)
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        sudo usermod -aG docker $USER
        echo "Docker installed. Please log out and log back in for group changes to take effect."
    fi

    # Install jq for JSON parsing
    sudo apt-get install -y jq

elif [ -f /etc/redhat-release ]; then
    # Red Hat/CentOS/Fedora
    echo "Installing on Red Hat-based system..."
    
    # Install AWS CLI v2
    echo "Installing AWS CLI v2..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws/

    # Install kubectl
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/

    # Install eksctl
    echo "Installing eksctl..."
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin

    # Install Docker (if not already installed)
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker $USER
        echo "Docker installed. Please log out and log back in for group changes to take effect."
    fi

    # Install jq
    sudo yum install -y jq

else
    echo "Unsupported operating system. Please install AWS CLI, kubectl, and eksctl manually."
    exit 1
fi

echo "Verifying installations..."
aws --version
kubectl version --client
eksctl version
docker --version

echo "All tools installed successfully!"
echo "Please run 'aws configure' to set up your AWS credentials."
echo "You may need to log out and log back in for Docker group changes to take effect."
