# Deployment Scripts for EKS

This guide provides comprehensive deployment scripts for your Go backend and React frontend applications on Amazon EKS.

## Prerequisites

### Install Required Tools on Linux

```bash
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Install Docker
sudo apt-get update
sudo apt-get install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm -y
```

## Setup Steps

1. Configure AWS credentials
2. Create EKS cluster with necessary IAM roles
3. Build and push Docker images to ECR
4. Deploy applications with Kubernetes manifests
5. Configure load balancing and storage

## Directory Structure After Setup

```
k8s/
├── cluster/
│   ├── cluster-config.yaml
│   └── iam-roles.yaml
├── deployments/
│   ├── backend-deployment.yaml
│   ├── frontend-deployment.yaml
│   ├── redis-deployment.yaml
│   └── postgres-deployment.yaml
├── services/
│   ├── backend-service.yaml
│   ├── frontend-service.yaml
│   ├── redis-service.yaml
│   └── postgres-service.yaml
├── storage/
│   ├── postgres-pvc.yaml
│   └── storage-class.yaml
├── ingress/
│   └── ingress.yaml
└── configmaps/
    ├── backend-config.yaml
    └── postgres-config.yaml
scripts/
├── setup-cluster.sh
├── build-and-push.sh
├── deploy-apps.sh
└── cleanup.sh
```
