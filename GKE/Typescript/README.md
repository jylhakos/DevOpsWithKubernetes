# TypeScript applications on Google Kubernetes Engine (GKE)

This project contains a complete setup for deploying TypeScript backend and frontend applications to Google Kubernetes Engine (GKE) with security, scaling, and monitoring capabilities.

## 🏗️ Project

```
├── backend/
│   ├── src/
│   │   └── server.ts
│   ├── Dockerfile
│   ├── package.json
│   ├── tsconfig.json
│   └── .dockerignore
├── frontend/
│   ├── src/
│   ├── public/
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── package.json
│   ├── tsconfig.json
│   └── .dockerignore
├── k8s/
│   ├── backend.yaml
│   ├── frontend.yaml
│   └── security.yaml
├── scripts/
│   ├── setup-tools.sh
│   ├── setup-gke.sh
│   ├── deploy.sh
│   ├── manage-scaling.sh
│   └── manage-containers.sh
└── README.md
```

## 🚀 Quick start

### Prerequisites

1. Google Cloud Platform account
2. Linux/macOS system
3. Internet connection

### Step 1: Setup tools

Install required tools (Google Cloud CLI, kubectl, Docker):

```bash
./scripts/setup-tools.sh
```

After installation, authenticate with Google Cloud:

```bash
gcloud auth login
gcloud auth configure-docker
```

### Step 2: Setup GKE cluster

Set your Google Cloud project ID:

```bash
export PROJECT_ID="your-gcp-project-id"
```

Create and configure the GKE cluster:

```bash
./scripts/setup-gke.sh
```

### Step 3: Deployment

Deploy both backend and frontend applications:

```bash
export PROJECT_ID="your-gcp-project-id"
./scripts/deploy.sh
```

## 🔧 Configuration

### Environment variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PROJECT_ID` | Google Cloud Project ID | `your-gcp-project-id` |
| `CLUSTER_NAME` | GKE cluster name | `typescript-cluster` |
| `ZONE` | GKE cluster zone | `us-central1-a` |
| `REGION` | GKE cluster region | `us-central1` |
| `BACKEND_IMAGE_TAG` | Backend Docker image tag | `latest` |
| `FRONTEND_IMAGE_TAG` | Frontend Docker image tag | `latest` |

### Customizing the setup

1. **Change cluster configuration**: Edit `scripts/setup-gke.sh`
2. **Modify resource limits**: Edit `k8s/backend.yaml` and `k8s/frontend.yaml`
3. **Update scaling settings**: Edit HPA configurations in the YAML files

## 📊 Managing and scaling

### Scaling

Scale backend to 5 replicas:
```bash
./scripts/manage-scaling.sh scale-backend 5
```

Scale frontend to 3 replicas:
```bash
./scripts/manage-scaling.sh scale-frontend 3
```

Update HPA settings:
```bash
./scripts/manage-scaling.sh update-backend-hpa 3 15 80
```

Update resource limits:
```bash
./scripts/manage-scaling.sh update-backend-resources 200m 256Mi 500m 512Mi
```

### Monitoring and management

Check deployment status:
```bash
./scripts/manage-scaling.sh status
```

Monitor resources in real-time:
```bash
./scripts/manage-scaling.sh monitor
```

View all resources:
```bash
./scripts/manage-containers.sh all
```

Check logs:
```bash
./scripts/manage-containers.sh logs backend 100
```

Port forward for local testing:
```bash
./scripts/manage-containers.sh port-forward frontend-service 80 8080
```

## 🔒 Security

### 1. Container security
- Multi-stage Docker builds
- Non-root user execution
- Security context configurations
- Health checks
- Resource limits

### 2. Kubernetes security
- Network policies for traffic control
- Service accounts with RBAC
- Pod security contexts
- Namespace isolation

### 3. GKE security
- Shielded nodes with secure boot
- Network policy enforcement
- Workload identity (can be enabled)
- Private clusters (can be configured)

## 🏗️ Architecture

### Backend
- **Technology**: Node.js + TypeScript + Express
- **Port**: 5000
- **Service Type**: ClusterIP
- **Scaling**: 2-10 replicas based on CPU/memory usage

### Frontend
- **Technology**: React + TypeScript + Nginx
- **Port**: 80
- **Service Type**: LoadBalancer
- **Scaling**: 2-10 replicas based on CPU/memory usage

### Networking
- Frontend publicly accessible via LoadBalancer
- Backend accessible only from frontend (network policies)
- DNS resolution within cluster

## 🛠️ Troubleshooting

### Issues

1. **Images not building**: Check Docker daemon is running
2. **Authentication errors**: Run `gcloud auth login`
3. **Cluster connection issues**: Run `gcloud container clusters get-credentials`
4. **Permission errors**: Check RBAC configurations

### Debugging

```bash
# Check cluster status
kubectl cluster-info

# View pod logs
kubectl logs -l app=backend -n typescript-app

# Describe problematic resources
kubectl describe pod <pod-name> -n typescript-app

# Check events
kubectl get events -n typescript-app --sort-by=.metadata.creationTimestamp
```

## 📈 Performance tuning

### Resource optimization

1. **CPU/Memory Requests**: Set based on actual usage
2. **Limits**: Set 2-3x higher than requests
3. **HPA Targets**: Use 70-80% for CPU, 80-90% for memory

### Scaling

```yaml
# Example HPA configuration
minReplicas: 2
maxReplicas: 10
metrics:
- type: Resource
  resource:
    name: cpu
    target:
      type: Utilization
      averageUtilization: 70
```

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
    - uses: actions/checkout@v2
    - name: Deploy
      run: |
        export PROJECT_ID="${{ secrets.GCP_PROJECT_ID }}"
        ./scripts/deploy.sh
```

## 🧹 Cleanup

To remove all resources:

```bash
./scripts/manage-containers.sh cleanup
```

To delete the GKE cluster:

```bash
gcloud container clusters delete typescript-cluster --zone=us-central1-a
```

## 📚 References

- [Google Kubernetes Engine Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/security/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License.
