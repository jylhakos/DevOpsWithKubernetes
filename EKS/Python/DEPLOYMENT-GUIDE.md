# ML pipeline deployment for Amazon EKS

## Overview

This document provides step-by-step instructions for deploying a machine learning pipeline consisting of three components:

1. **ml-training**: Python script that downloads images and trains a CNN model
2. **ml-backend**: Flask API that serves the trained model on port 5000
3. **ml-frontend**: React application that provides a UI for image classification on port 3000

## Architecture

```
Internet → ALB → Frontend (React) → Backend API (Flask) → CNN Model
                                            ↑
                                    Training Job (Creates Model)
                                            ↑
                                    Shared EFS Storage
```

## Deployment flow

### 1. Infrastructure

The deployment follows this order to ensure proper dependencies:

1. **Storage setup**: EFS file system and persistent volume claims
2. **Training**: Runs once to create the CNN model
3. **Backend srvice**: Waits for model to be available
4. **Frontend service**: Connects to backend API
5. **Load Balancer**: Exposes services externally

### 2. Data flow

1. Training job downloads images to `/src/imgs`
2. Training job processes images and creates CSV files in `/src/data`
3. Training job trains CNN model and saves to `/src/model`
4. Backend service loads the model from `/src/model`
5. Frontend uploads images to backend for classification
6. Backend processes images using the CNN model and returns predictions

## Prerequisites

### AWS resources

1. **EKS Cluster** with managed node groups
2. **EFS File System** for shared storage
3. **ECR Repositories** for container images
4. **IAM Roles** with appropriate permissions
5. **Application Load Balancer** (optional, for ingress)
6. **SSL Certificate** (optional, for HTTPS)

### Required AWS services

- Amazon EKS
- Amazon ECR
- Amazon EFS
- Amazon EC2
- AWS IAM
- AWS Load Balancer Controller

## Step-by-step deployment

### Step 1: Prepare AWS infrastructure

```bash
# 1. Create EKS cluster
eksctl create cluster --name ml-pipeline-cluster --region us-west-2 --node-type m5.large --nodes 3

# 2. Install AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system

# 3. Install EFS CSI Driver
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

# 4. Create EFS file system
aws efs create-file-system --performance-mode generalPurpose --tags Key=Name,Value=ml-pipeline-efs
```

### Step 2: Configure Kubernetes resources

```bash
# Apply in this order:
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/rbac.yaml
kubectl apply -f k8s/efs-storageclass.yaml
kubectl apply -f k8s/storage.yaml
```

### Step 3: Build and push container images

```bash
# Build and push to ECR
./aws-setup/deploy.sh
```

### Step 4: Deploy applications

```bash
# 1. Start training job first
kubectl apply -f k8s/ml-training-job.yaml

# 2. Wait for training to complete
kubectl wait --for=condition=complete job/ml-training-job -n ml-pipeline --timeout=1800s

# 3. Deploy backend (depends on trained model)
kubectl apply -f k8s/ml-backend.yaml

# 4. Wait for backend to be ready
kubectl wait --for=condition=available deployment/ml-backend -n ml-pipeline --timeout=300s

# 5. Deploy frontend
kubectl apply -f k8s/ml-frontend.yaml

# 6. Apply autoscaling and ingress
kubectl apply -f k8s/hpa.yaml
kubectl apply -f k8s/ingress.yaml
```

### Step 5: Verify deployment

```bash
# Check all resources
kubectl get all -n ml-pipeline

# Check training job logs
kubectl logs job/ml-training-job -n ml-pipeline

# Check backend logs
kubectl logs deployment/ml-backend -n ml-pipeline

# Check frontend logs
kubectl logs deployment/ml-frontend -n ml-pipeline

# Get external URL
kubectl get ingress -n ml-pipeline
```

## Configuration

### Environment variables

- `FLASK_ENV=production` for backend
- `REACT_APP_BACKEND_URL` for frontend API endpoint
- `PYTHONUNBUFFERED=1` for real-time Python logs

### Volume mounts

- `/src/model`: Shared model storage (EFS)
- `/src/data`: Training data storage (EFS)
- `/src/imgs`: Downloaded images storage (EFS)

### Resource limits

- **Training Job**: 2 CPU, 4GB RAM
- **Backend**: 1 CPU, 2GB RAM
- **Frontend**: 0.5 CPU, 512MB RAM

### Security

- Non-root containers
- Read-only root filesystems where possible
- RBAC with minimal permissions
- Service accounts with IAM roles
- Network policies (optional)

## Monitoring and troubleshooting

### Health checks

- Backend: `GET /ping`
- Frontend: `GET /` (homepage)

### Issues

1. **Training job fails**: Check EFS mount and permissions
2. **Backend can't find model**: Ensure training completed successfully
3. **Frontend can't reach backend**: Check service networking
4. **Resource constraints**: Monitor CPU/memory usage

### Scaling

- HPA automatically scales based on CPU/memory usage
- Manual scaling: `kubectl scale deployment ml-backend --replicas=5 -n ml-pipeline`

## Production

1. **Monitoring**: Add Prometheus/Grafana for metrics
2. **Logging**: Configure centralized logging with Fluentd/ELK
3. **Backup**: Regular backups of model and training data
4. **Security**: Network policies, pod security policies
5. **Cost Optimization**: Use spot instances for training jobs
6. **CI/CD**: Automate deployments with GitOps

## Cleanup

```bash
# Delete cluster and all resources
eksctl delete cluster --name ml-pipeline-cluster --region us-west-2
```