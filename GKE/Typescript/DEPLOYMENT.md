# Deployment of TypeScript applications on GKE

## 📋 Checklist

### 1. Prerequisites
- [ ] Google Cloud Platform account with billing enabled
- [ ] Administrative access to create GKE clusters
- [ ] Linux/macOS machine with internet connection
- [ ] Domain name (optional, for custom domains)

### 2. Environment Setup
- [ ] Install required tools using `./scripts/setup-tools.sh`
- [ ] Authenticate with Google Cloud: `gcloud auth login`
- [ ] Configure Docker for GCR: `gcloud auth configure-docker`
- [ ] Set project ID: `export PROJECT_ID="your-gcp-project-id"`

## 🚀 Steps

### Step 1: Initial setup
```bash
# 1. Clone/navigate to project directory
cd /path/to/your/project

# 2. Make scripts executable
chmod +x scripts/*.sh

# 3. Install tools
./scripts/setup-tools.sh

# 4. Login to Google Cloud
gcloud auth login
gcloud auth configure-docker
```

### Step 2: Configure project
```bash
# 1. Set your project ID
export PROJECT_ID="your-actual-gcp-project-id"

# 2. Create .env file from example
cp .env.example .env
# Edit .env with your values
```

### Step 3: Create GKE cluster
```bash
# This will create a production-ready GKE cluster
./scripts/setup-gke.sh
```

### Step 4: Deploy applications
```bash
# This will build Docker images and deploy to GKE
./scripts/deploy.sh
```

### Step 5: Verify deployment
```bash
# Check deployment status
./scripts/manage-scaling.sh status

# Get service URLs
kubectl get services -n typescript-app
```

## 🔧 Configuration options

### Environment variables
Edit `.env` file with your specific values:

```bash
# Required
PROJECT_ID="your-gcp-project-id"

# Optional (have defaults)
CLUSTER_NAME="typescript-cluster"
ZONE="us-central1-a"
REGION="us-central1"
```

### Cluster configuration
Edit `scripts/setup-gke.sh` to modify:
- Machine type (default: e2-medium)
- Node count (default: 3)
- Zone/region
- Security features

### Resource limits
Edit `k8s/backend.yaml` and `k8s/frontend.yaml` to modify:
- CPU/memory requests and limits
- Replica counts
- Environment variables

## 🛡️ Security

### 1. Network security
```bash
# Network policies are automatically applied
# They restrict traffic between pods
kubectl get networkpolicies -n typescript-app
```

### 2. RBAC (Role-Based Access Control)
```bash
# Service accounts and roles are created automatically
kubectl get serviceaccounts -n typescript-app
kubectl get roles -n typescript-app
```

### 3. Pod security
- Non-root user execution
- Read-only root filesystem
- Dropped capabilities
- Security contexts

## 📊 Monitoring and scaling

### Horizontal Pod Autoscaler (HPA)
```bash
# View current HPA status
kubectl get hpa -n typescript-app

# Scale manually
./scripts/manage-scaling.sh scale-backend 5

# Update HPA settings
./scripts/manage-scaling.sh update-backend-hpa 3 15 80
```

### Resource monitoring
```bash
# Real-time monitoring
./scripts/manage-scaling.sh monitor

# Check resource usage
kubectl top pods -n typescript-app
kubectl top nodes
```

## 🔍 Troubleshooting

### Issues and solutions

#### 1. Authentication
```bash
# Re-authenticate
gcloud auth login
gcloud auth configure-docker

# Check authentication
gcloud auth list
```

#### 2. Cluster Access
```bash
# Get cluster credentials
gcloud container clusters get-credentials typescript-cluster --zone=us-central1-a

# Check cluster connection
kubectl cluster-info
```

#### 3. Image push
```bash
# Check Docker daemon
sudo systemctl status docker

# Check GCR permissions
gcloud auth configure-docker
```

#### 4. Pod
```bash
# Check pod status
kubectl get pods -n typescript-app

# View pod logs
kubectl logs -l app=backend -n typescript-app --tail=50

# Describe problematic pod
kubectl describe pod <pod-name> -n typescript-app
```

#### 5. Service
```bash
# Check services
kubectl get services -n typescript-app

# Check endpoints
kubectl get endpoints -n typescript-app

# Port forward for testing
kubectl port-forward service/frontend-service 8080:80 -n typescript-app
```

### Debugging

```bash
# Get all resources
kubectl get all -n typescript-app

# Check events
kubectl get events -n typescript-app --sort-by=.metadata.creationTimestamp

# Check node status
kubectl get nodes

# Check cluster health
kubectl get componentstatuses
```

## 🚀 Production

### 1. Domain and SSL
```bash
# Reserve static IP
gcloud compute addresses create typescript-app-ip --global

# Update ingress.yaml with your domain
# Apply ingress configuration
kubectl apply -f k8s/ingress.yaml
```

### 2. Resource optimization
- Set appropriate resource requests/limits
- Use HPA for automatic scaling
- Monitor resource usage regularly

### 3. Hardening
- Enable Workload Identity
- Use private clusters
- Regular security updates
- Network policies

### 4. Backup and recovery
- Regular cluster snapshots
- Persistent volume backups
- Application state backup

## 🔄 CI/CD

### GitHub Actions
```yaml
name: Deploy to GKE
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup Cloud SDK
      uses: google-github-actions/setup-gcloud@v1
      with:
        project_id: ${{ secrets.GCP_PROJECT_ID }}
        service_account_key: ${{ secrets.GCP_SA_KEY }}
    - name: Deploy
      run: |
        export PROJECT_ID="${{ secrets.GCP_PROJECT_ID }}"
        ./scripts/deploy.sh
```

### GitLab CI
```yaml
deploy:
  stage: deploy
  image: google/cloud-sdk:latest
  script:
    - gcloud auth activate-service-account --key-file $GCP_SERVICE_KEY
    - export PROJECT_ID=$GCP_PROJECT_ID
    - ./scripts/deploy.sh
  only:
    - main
```

## 📈 Performance tuning

### 1. Resource optimization
```bash
# Monitor resource usage
kubectl top pods -n typescript-app

# Adjust resources based on usage
./scripts/manage-scaling.sh update-backend-resources 200m 256Mi 500m 512Mi
```

### 2. Scaling
```bash
# Optimize HPA settings
./scripts/manage-scaling.sh update-backend-hpa 2 20 70
```

### 3. Node optimization
```bash
# Check node utilization
kubectl describe nodes

# Consider node auto-scaling
gcloud container clusters update typescript-cluster --enable-autoscaling --min-nodes=1 --max-nodes=10 --zone=us-central1-a
```

## 🧹 Cleanup

### Remove applications
```bash
# Delete namespace and all resources
./scripts/manage-containers.sh cleanup
```

### Remove cluster
```bash
# Delete the entire cluster
gcloud container clusters delete typescript-cluster --zone=us-central1-a
```

### Remove images
```bash
# Delete Docker images from GCR
gcloud container images delete gcr.io/$PROJECT_ID/backend:latest
gcloud container images delete gcr.io/$PROJECT_ID/frontend:latest
```

## 📞 Support

### Help
1. Check logs: `./scripts/manage-containers.sh logs <app>`
2. Review events: `kubectl get events -n typescript-app`
3. Check resource usage: `./scripts/manage-scaling.sh status`
4. Consult Google Cloud documentation
5. Review Kubernetes documentation

### Resources
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)

## 🎯 Next Steps

After successful deployment:
1. Set up monitoring and alerting
2. Configure CI/CD pipeline
3. Implement proper backup strategy
4. Set up staging environment
5. Configure custom domain and SSL
6. Implement additional security measures
