# AWS EKS ML Pipeline Infrastructure Setup

This directory contains the necessary configurations and scripts to set up the AWS infrastructure for the ML Pipeline on EKS.

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. kubectl installed
3. eksctl installed
4. helm installed
5. Docker installed

## Setup Instructions

### 1. Create EKS Cluster

```bash
# Create EKS cluster with managed node groups
eksctl create cluster \
  --name ml-pipeline-cluster \
  --region us-west-2 \
  --node-type m5.large \
  --nodes 3 \
  --nodes-min 2 \
  --nodes-max 5 \
  --managed \
  --enable-ssm \
  --alb-ingress-access \
  --full-ecr-access

# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name ml-pipeline-cluster
```

### 2. Install Required Add-ons

```bash
# Install AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=ml-pipeline-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

# Install EFS CSI Driver
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

# Install Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### 3. Create ECR Repositories

```bash
# Create ECR repositories for each service
aws ecr create-repository --repository-name ml-training --region us-west-2
aws ecr create-repository --repository-name ml-backend --region us-west-2
aws ecr create-repository --repository-name ml-frontend --region us-west-2
```

### 4. Create EFS File System

```bash
# Create EFS file system
aws efs create-file-system \
  --performance-mode generalPurpose \
  --throughput-mode provisioned \
  --provisioned-throughput-in-mibps 100 \
  --tags Key=Name,Value=ml-pipeline-efs
```

### 5. Build and Push Docker Images

```bash
# Login to ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com

# Build and push images
docker build -t ml-training ./ml-training
docker tag ml-training:latest YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/ml-training:latest
docker push YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/ml-training:latest

docker build -t ml-backend ./ml-backend
docker tag ml-backend:latest YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/ml-backend:latest
docker push YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/ml-backend:latest

docker build -t ml-frontend ./ml-frontend
docker tag ml-frontend:latest YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/ml-frontend:latest
docker push YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/ml-frontend:latest
```

### 6. Deploy to Kubernetes

```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/rbac.yaml
kubectl apply -f k8s/efs-storageclass.yaml
kubectl apply -f k8s/storage.yaml
kubectl apply -f k8s/ml-training-job.yaml
kubectl apply -f k8s/ml-backend.yaml
kubectl apply -f k8s/ml-frontend.yaml
kubectl apply -f k8s/hpa.yaml
kubectl apply -f k8s/ingress.yaml
```

## Monitoring and Maintenance

```bash
# Check deployment status
kubectl get all -n ml-pipeline

# Check training job logs
kubectl logs -f job/ml-training-job -n ml-pipeline

# Check backend logs
kubectl logs -f deployment/ml-backend -n ml-pipeline

# Scale deployments
kubectl scale deployment ml-backend --replicas=3 -n ml-pipeline
```

## Cleanup

```bash
# Delete cluster
eksctl delete cluster --name ml-pipeline-cluster --region us-west-2
```
