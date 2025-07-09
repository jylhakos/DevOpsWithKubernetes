# Go application deployment on Google GKE

This project contains a Go web application with PostgreSQL database and Redis cache, configured for deployment on Google Kubernetes Engine (GKE).

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Load Balancer │────│   Go App Pods   │────│   PostgreSQL    │
│    (Ingress)    │    │   (3 replicas)  │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                │
                       ┌─────────────────┐
                       │      Redis      │
                       │     (Cache)     │
                       └─────────────────┘
```

## Prerequisites

### Local development tools

Run the installation script to install all required tools:

```bash
./install-tools.sh
```

Or install manually:

1. **Docker** - Container platform
2. **Google Cloud SDK** - GCP command-line tools
3. **kubectl** - Kubernetes command-line tool
4. **Helm** (optional) - Kubernetes package manager

### Google Cloud setup

1. **Create a GCP project**
   ```bash
   gcloud projects create YOUR_PROJECT_ID
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **Enable required APIs**
   ```bash
   gcloud services enable container.googleapis.com
   gcloud services enable containerregistry.googleapis.com
   ```

3. **Authenticate**
   ```bash
   gcloud auth login
   gcloud auth configure-docker
   ```

## Project

```
.
├── app.go                  # Main application
├── health.go              # Health check endpoints
├── Dockerfile             # Multi-stage Docker build
├── docker-compose.yml     # Local development
├── go.mod                 # Go modules
├── deploy.sh              # Automated deployment script
├── install-tools.sh       # Tool installation script
├── k8s/                   # Kubernetes manifests
│   ├── namespace.yaml     # Namespace definition
│   ├── configmap.yaml     # Configuration
│   ├── secret.yaml        # Sensitive data
│   ├── postgres-pvc.yaml  # PostgreSQL storage
│   ├── postgres.yaml      # PostgreSQL deployment
│   ├── redis-pvc.yaml     # Redis storage
│   ├── redis.yaml         # Redis deployment
│   ├── go-app-deployment.yaml # App deployment
│   ├── go-app-service.yaml    # App service
│   ├── ingress.yaml       # External access
│   └── hpa.yaml          # Auto-scaling
├── cache/                 # Redis utilities
├── common/               # Common utilities
├── controller/           # Controllers
├── pgconnection/         # PostgreSQL utilities
└── router/               # HTTP router
```

## Quick start

### 1. Local development

Start the application locally with Docker Compose:

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### 2. Deploy to GKE

#### Automated deployment

```bash
# Set your project ID
export PROJECT_ID="your-gcp-project-id"
export CLUSTER_NAME="go-app-cluster"
export REGION="us-central1-a"

# Run the deployment script
./deploy.sh
```

#### Manual deployment

1. **Build and push Docker image**
   ```bash
   # Build the image
   docker build -t gcr.io/$PROJECT_ID/go-app:latest .
   
   # Push to Google Container Registry
   docker push gcr.io/$PROJECT_ID/go-app:latest
   ```

2. **Create GKE cluster**
   ```bash
   gcloud container clusters create go-app-cluster \
     --zone=us-central1-a \
     --machine-type=e2-medium \
     --num-nodes=3 \
     --enable-autoscaling \
     --min-nodes=1 \
     --max-nodes=5
   ```

3. **Get cluster credentials**
   ```bash
   gcloud container clusters get-credentials go-app-cluster --zone=us-central1-a
   ```

4. **Deploy to Kubernetes**
   ```bash
   # Update the image in deployment manifest
   sed -i "s|gcr.io/YOUR_PROJECT_ID/go-app:latest|gcr.io/$PROJECT_ID/go-app:latest|g" k8s/go-app-deployment.yaml
   
   # Apply all manifests
   kubectl apply -f k8s/
   ```

## Configuration

### Environment variables

The application uses the following environment variables:

- `PORT` - Server port (default: 8080)
- `POSTGRES_HOST` - PostgreSQL hostname
- `POSTGRES_PORT` - PostgreSQL port
- `POSTGRES_DB` - Database name
- `POSTGRES_USER` - Database username
- `POSTGRES_PASSWORD` - Database password
- `REDIS_HOST` - Redis hostname
- `REDIS_PORT` - Redis port

### Kubernetes configuration

- **ConfigMap**: Non-sensitive configuration
- **Secret**: Sensitive data (passwords, keys)
- **PersistentVolumeClaim**: Storage for databases
- **HorizontalPodAutoscaler**: Auto-scaling based on CPU/memory

## Monitoring and health checks

### Health endpoints

- `GET /health` - Basic health check
- `GET /ready` - Readiness check (includes database connectivity)

### Monitoring commands

```bash
# Check pod status
kubectl get pods -n go-app

# View logs
kubectl logs -f deployment/go-app-deployment -n go-app

# Check service endpoints
kubectl get endpoints -n go-app

# Monitor resource usage
kubectl top pods -n go-app
```

## Scaling

### Manual

```bash
# Scale the application
kubectl scale deployment go-app-deployment --replicas=5 -n go-app
```

### Auto-scaling

The HPA (HorizontalPodAutoscaler) automatically scales based on:
- CPU utilization (target: 70%)
- Memory utilization (target: 80%)
- Min replicas: 2
- Max replicas: 10

## Security

1. **Secrets**: Use Kubernetes secrets for sensitive data
2. **Network policies**: Implement network segmentation (not included in basic setup)
3. **RBAC**: Use Role-Based Access Control for Kubernetes API access
4. **Image security**: Regular image updates and vulnerability scanning
5. **Resource limits**: Set resource requests and limits for all containers

## Troubleshooting

### Issues

1. **Image pull errors**
   ```bash
   # Check image exists
   gcloud container images list --repository=gcr.io/$PROJECT_ID
   
   # Check authentication
   gcloud auth configure-docker
   ```

2. **Database connection issues**
   ```bash
   # Check PostgreSQL pod
   kubectl logs deployment/postgres-deployment -n go-app
   
   # Test connection from app pod
   kubectl exec -it deployment/go-app-deployment -n go-app -- ping postgres-service
   ```

3. **Service discovery issues**
   ```bash
   # Check services
   kubectl get svc -n go-app
   
   # Check endpoints
   kubectl get endpoints -n go-app
   ```

### Debug

```bash
# Get cluster info
kubectl cluster-info

# Describe resources
kubectl describe deployment go-app-deployment -n go-app
kubectl describe pod <pod-name> -n go-app

# Check events
kubectl get events -n go-app --sort-by='.lastTimestamp'

# Access application shell
kubectl exec -it deployment/go-app-deployment -n go-app -- /bin/sh
```

## Cost optimization

1. **Right-sizing**: Monitor resource usage and adjust requests/limits
2. **Node auto-scaling**: Use cluster autoscaling
3. **Preemptible nodes**: Consider preemptible instances for development
4. **Resource quotas**: Set namespace resource quotas

## Cleanup

```bash
# Delete the application
kubectl delete namespace go-app

# Delete the cluster
gcloud container clusters delete go-app-cluster --zone=us-central1-a

# Delete Docker images
gcloud container images delete gcr.io/$PROJECT_ID/go-app:latest
```

## Prerequisites for development

Install [golang](https://golang.org/doc/install) 1.16

## Build project

Run `go build`. It will generate a binary named "server"

## Test project #

Run tests with `go test ./...`.

## Environment

Execute the file e.g. `./server`.

> In exercise 1.12 and after you will need to add some environment variables. Not everything is important for all exercises and some may be useless.

Server accepts the following environment variables:

- `PORT` to choose which port for the application. Default: 8080

- In 1.12 and after
  - `REQUEST_ORIGIN` to pass an url through the cors check. Default: https://example.com

- In 2.4 and after
  - `REDIS_HOST` The hostname for redis. (port will default to 6379, the default for Redis)

- In 2.6 and after
  - `POSTGRES_HOST` The hostname for postgres database. (port will default to 5432 the default for Postgres)
  - `POSTGRES_USER` database user. Default: postgres
  - `POSTGRES_PASSWORD` database password. Default: postgres
  - `POSTGRES_DATABASE` database name. Default: postgres
