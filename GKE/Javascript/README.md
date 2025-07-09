# React frontend - Google GKE deployment

This document explains how to deploy a React frontend application to Google Kubernetes Engine (GKE) using Docker and Kubernetes.

## Prerequisites

- Google Cloud Platform account
- GCP project with billing enabled
- Local Linux machine with bash shell

## Project

```
├── k8s/                    # Kubernetes YAML files
│   ├── deployment.yaml     # Main deployment configuration
│   ├── service.yaml        # Service configuration
│   ├── configmap.yaml      # Configuration management
│   ├── ingress.yaml        # Ingress for external access
│   ├── ssl-certificate.yaml # SSL certificate
│   └── hpa.yaml           # Horizontal Pod Autoscaler
├── scripts/               # Deployment scripts
│   ├── setup-local-env.sh  # Local environment setup
│   ├── setup-gke-cluster.sh # GKE cluster creation
│   ├── deploy-to-gke.sh    # Application deployment
│   └── cleanup.sh          # Resource cleanup
├── docker-compose.yml     # Local development
├── Dockerfile            # Container configuration
└── README.md             # This file
```

## Quick start

### 1. Set up local environment

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Install required tools (Docker, gcloud, kubectl, helm)
./scripts/setup-local-env.sh
```

### 2. Authenticate with Google Cloud

```bash
# Login to Google Cloud
gcloud auth login

# Set your project ID
gcloud config set project YOUR_PROJECT_ID

# Authenticate Docker with GCR
gcloud auth configure-docker
```

### 3. Create GKE cluster

```bash
# Create a new GKE cluster
./scripts/setup-gke-cluster.sh YOUR_PROJECT_ID react-frontend-cluster us-central1-a
```

### 4. Deploy the application

```bash
# Build and deploy to GKE
./scripts/deploy-to-gke.sh YOUR_PROJECT_ID react-frontend-cluster us-central1-a
```

### 5. Access your application

```bash
# Get the external IP address
kubectl get service react-frontend-service

# Wait for LoadBalancer to assign an external IP
watch kubectl get service react-frontend-service
```

## Detailed setup

### Local development

1. **Test locally with Docker Compose:**
   ```bash
   docker-compose up --build
   ```
   Access at: http://localhost:3000

2. **Test locally with Docker:**
   ```bash
   docker build -t react-frontend .
   docker run -p 3000:5000 react-frontend
   ```

### Production

1. **Manual cluster creation:**
   ```bash
   gcloud container clusters create react-frontend-cluster \
     --zone=us-central1-a \
     --num-nodes=3 \
     --machine-type=e2-medium \
     --enable-autoscaling \
     --min-nodes=1 \
     --max-nodes=10
   ```

2. **Manual deployment:**
   ```bash
   # Build and push image
   docker build -t gcr.io/YOUR_PROJECT_ID/react-frontend:latest .
   docker push gcr.io/YOUR_PROJECT_ID/react-frontend:latest
   
   # Deploy to Kubernetes
   kubectl apply -f k8s/
   ```

## Required Tools

### Local Linux

1. **Docker** - Container platform
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   ```

2. **Google Cloud SDK** - GCP command-line tools
   ```bash
   curl https://sdk.cloud.google.com | bash
   ```

3. **kubectl** - Kubernetes command-line tool
   ```bash
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   chmod +x kubectl
   sudo mv kubectl /usr/local/bin/
   ```

4. **Helm** (Optional) - Kubernetes package manager
   ```bash
   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
   ```

### Google Cloud services

1. **Google Kubernetes Engine (GKE)** - Managed Kubernetes service
2. **Google Container Registry (GCR)** - Container image registry
3. **Google Cloud Load Balancer** - External load balancing
4. **Google Cloud DNS** (Optional) - Domain name management

## Kubernetes resources

### Deployment (`deployment.yaml`)
- Manages 3 replicas of the React frontend
- Configures resource limits and health checks
- Uses rolling updates for zero-downtime deployments

### Service (`service.yaml`)
- Exposes the application with a LoadBalancer
- Routes traffic to healthy pods
- Provides stable networking endpoint

### ConfigMap (`configmap.yaml`)
- Stores configuration data
- Environment variables for the application
- Separates config from application code

### Horizontal Pod Autoscaler (`hpa.yaml`)
- Automatically scales pods based on CPU/memory usage
- Scales from 2 to 10 replicas
- Maintains performance under load

### Ingress (`ingress.yaml`)
- Provides external HTTP/HTTPS access
- SSL termination with Google-managed certificates
- Custom domain support

## Monitoring and management

### View logs
```bash
kubectl logs -l app=react-frontend
```

### Scaling
```bash
kubectl scale deployment react-frontend-deployment --replicas=5
```

### Update the application
```bash
# Build new image
docker build -t gcr.io/YOUR_PROJECT_ID/react-frontend:v2 .
docker push gcr.io/YOUR_PROJECT_ID/react-frontend:v2

# Update deployment
kubectl set image deployment/react-frontend-deployment react-frontend=gcr.io/YOUR_PROJECT_ID/react-frontend:v2
```

### Monitor cluster
```bash
# Get cluster info
kubectl cluster-info

# View nodes
kubectl get nodes

# View all resources
kubectl get all
```

## Cost optimization

1. **Use preemptible nodes** (for development):
   ```bash
   gcloud container clusters create react-frontend-cluster --preemptible
   ```

2. **Enable cluster autoscaling:**
   ```bash
   gcloud container clusters update react-frontend-cluster --enable-autoscaling --min-nodes=1 --max-nodes=10
   ```

3. **Use appropriate machine types:**
   - Development: `e2-micro` or `e2-small`
   - Production: `e2-medium` or `e2-standard-2`

## Security

1. **Use least privilege IAM roles**
2. **Enable network policies**
3. **Use secrets for sensitive data**
4. **Regular security updates**
5. **Enable audit logging**

## Troubleshooting

### Issues

1. **Image pull errors:**
   ```bash
   # Check authentication
   gcloud auth configure-docker
   ```

2. **Service not accessible:**
   ```bash
   # Check service status
   kubectl get svc
   kubectl describe svc react-frontend-service
   ```

3. **Pods not starting:**
   ```bash
   # Check pod logs
   kubectl logs -l app=react-frontend
   kubectl describe pod <pod-name>
   ```

### Commands

```bash
# Get cluster credentials
gcloud container clusters get-credentials CLUSTER_NAME --zone=ZONE

# Port forward for local access
kubectl port-forward svc/react-frontend-service 8080:80

# Execute commands in pod
kubectl exec -it <pod-name> -- /bin/sh

# View resource usage
kubectl top nodes
kubectl top pods
```

## Cleanup

To remove all resources and avoid charges:

```bash
./scripts/cleanup.sh YOUR_PROJECT_ID react-frontend-cluster us-central1-a
```

## Support

For issues with:
- **GKE**: Check [Google Cloud documentation](https://cloud.google.com/kubernetes-engine/docs)
- **Kubernetes**: Check [Kubernetes documentation](https://kubernetes.io/docs/)
- **Docker**: Check [Docker documentation](https://docs.docker.com/)

## License

This project is licensed under the MIT License.
