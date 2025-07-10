# GKE deployment for Go backend + React frontend

This project provides a complete setup for deploying a Go backend and React frontend application to Google Kubernetes Engine (GKE) with Redis caching and PostgreSQL database.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│   Frontend      │────▶   Backend       │────▶   PostgreSQL    │
│   (React)       │    │   (Go)          │    │   Database      │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                │
                                ▼
                       ┌─────────────────┐
                       │                 │
                       │   Redis Cache   │
                       │                 │
                       └─────────────────┘
```

## Features

- **Go Backend**: REST API with health checks and database/cache connectivity
- **React Frontend**: Modern web interface
- **Redis Caching**: In-memory caching for performance
- **PostgreSQL**: Persistent data storage
- **Kubernetes**: Container orchestration with GKE
- **Security**: RBAC, Network Policies, and security best practices
- **Monitoring**: Health checks and resource monitoring
- **Auto-scaling**: Horizontal Pod Autoscaler (HPA)
- **Load Balancing**: Google Cloud Load Balancer
- **SSL/TLS**: Managed certificates for HTTPS

## API endpoints

- `GET /ping` - Basic health check
- `GET /ping?redis=true` - Test Redis connectivity
- `GET /ping?postgres=true` - Test PostgreSQL connectivity
- `GET /messages` - Get messages from database
- `POST /messages` - Create new message

## Prerequisites

- Linux system (Ubuntu/Debian preferred)
- Google Cloud Platform account
- Domain names for your application (optional, for SSL)

## Quick start

### 1. Initial setup

Run the setup script to install all required tools:

```bash
./scripts/setup.sh
```

This script installs:
- Docker
- Google Cloud SDK (gcloud)
- kubectl
- Helm

### 2. Configure Google Cloud

```bash
# Authenticate with Google Cloud
gcloud auth login

# Set your project ID
gcloud config set project YOUR_PROJECT_ID

# Enable billing for your project (required for GKE)
```

### 3. Update configuration

Edit the deployment script with your project details:

```bash
# Edit scripts/deploy.sh
PROJECT_ID="your-gcp-project-id"
CLUSTER_NAME="myapp-cluster"
ZONE="us-central1-a"
```

### 4. Deploy to GKE

```bash
./scripts/deploy.sh
```

This script will:
1. Create a GKE cluster
2. Reserve static IP addresses
3. Build and push Docker images
4. Deploy all Kubernetes resources
5. Configure load balancing and SSL

### 5. Monitor and maintain

```bash
./scripts/monitor.sh
```

This provides an interactive menu for:
- Viewing cluster status
- Checking application health
- Monitoring resource usage
- Scaling deployments
- Updating images
- Creating database backups

## Local development

For local development, use Docker Compose:

```bash
# Build and run locally
docker-compose up --build

# Access applications
# Frontend: http://localhost:5000
# Backend: http://localhost:8000
```

## File structure

```
├── backend/                 # Go backend application
│   ├── app.go              # Main application file
│   ├── Dockerfile          # Backend Docker image
│   ├── router/             # HTTP routing
│   ├── controller/         # Request handlers
│   ├── cache/              # Redis integration
│   └── pgconnection/       # PostgreSQL integration
├── frontend/               # React frontend application
│   ├── src/                # React source code
│   ├── public/             # Static assets
│   ├── Dockerfile          # Frontend Docker image
│   └── package.json        # Node.js dependencies
├── k8s/                    # Kubernetes manifests
│   ├── namespace.yaml      # Namespace definition
│   ├── configmap.yaml      # Configuration data
│   ├── security.yaml       # RBAC and security policies
│   ├── postgres.yaml       # PostgreSQL deployment
│   ├── redis.yaml          # Redis deployment
│   ├── backend.yaml        # Backend deployment
│   ├── frontend.yaml       # Frontend deployment
│   └── scaling.yaml        # Auto-scaling configuration
├── scripts/                # Deployment scripts
│   ├── setup.sh           # Initial setup
│   ├── deploy.sh          # Main deployment script
│   ├── monitor.sh         # Monitoring and maintenance
│   └── cleanup.sh         # Resource cleanup
└── docker-compose.yml     # Local development setup
```

## Kubernetes

### Security

- **Namespace isolation**: All resources in dedicated namespace
- **RBAC**: Role-based access control
- **Network policies**: Restrict pod-to-pod communication
- **Secrets management**: Secure storage of sensitive data
- **Resource limits**: CPU and memory constraints

### Scaling and availability

- **Horizontal Pod Autoscaler**: Auto-scale based on CPU/memory
- **Pod Disruption Budgets**: Ensure minimum availability
- **Health checks**: Liveness and readiness probes
- **Rolling updates**: Zero-downtime deployments

### Storage

- **Persistent volumes**: PostgreSQL data persistence
- **Volume claims**: Storage management
- **Backup support**: Database backup capabilities

## Monitoring and logging

### Health checks

All services include health checks:
- Backend: `curl http://backend:8080/ping`
- Frontend: `curl http://frontend:5000/`
- Redis: `redis-cli ping`
- PostgreSQL: `pg_isready`

### Resource monitoring

```bash
# Check resource usage
kubectl top pods -n myapp-namespace
kubectl top nodes

# View logs
kubectl logs -f deployment/backend-deployment -n myapp-namespace
kubectl logs -f deployment/frontend-deployment -n myapp-namespace
```

## Troubleshooting

### Issues

1. **Image pull errors**:
   ```bash
   # Ensure Docker is authenticated
   gcloud auth configure-docker
   ```

2. **Database connection issues**:
   ```bash
   # Check PostgreSQL pod status
   kubectl get pods -n myapp-namespace -l app=postgres
   
   # Check logs
   kubectl logs -f deployment/postgres-deployment -n myapp-namespace
   ```

3. **Redis connection issues**:
   ```bash
   # Test Redis connectivity
   kubectl exec -it deployment/redis-deployment -n myapp-namespace -- redis-cli ping
   ```

### Debugging

```bash
# Check pod status
kubectl get pods -n myapp-namespace

# Describe pod for detailed info
kubectl describe pod POD_NAME -n myapp-namespace

# Get pod logs
kubectl logs POD_NAME -n myapp-namespace

# Execute commands in pod
kubectl exec -it POD_NAME -n myapp-namespace -- /bin/sh
```

## Cost optimization

### Resource limits

All deployments include resource limits:
- Backend: 256Mi-512Mi memory, 250m-500m CPU
- Frontend: 128Mi-256Mi memory, 100m-200m CPU
- PostgreSQL: 256Mi-512Mi memory, 250m-500m CPU
- Redis: 128Mi-256Mi memory, 100m-200m CPU

### Auto-scaling configuration

- Minimum replicas: 3
- Maximum replicas: 10
- Scale up: CPU > 70% or Memory > 80%
- Scale down: CPU < 50% and Memory < 60%

## Security

1. **Network Security**:
   - Network policies restrict traffic between pods
   - Only necessary ports are exposed
   - Ingress controllers handle external traffic

2. **Authentication**:
   - Service accounts with minimal permissions
   - RBAC policies for fine-grained access control

3. **Data Security**:
   - Secrets for sensitive configuration
   - Encrypted communication between services
   - Regular security updates

## Backup and recovery

### Database backups

```bash
# Create backup
./scripts/monitor.sh
# Select option 8 for database backup

# Manual backup
kubectl exec -it deployment/postgres-deployment -n myapp-namespace -- pg_dump -U postgres postgres > backup.sql
```

### Disaster recovery

```bash
# Scale down application
kubectl scale deployment backend-deployment --replicas=0 -n myapp-namespace

# Restore database
kubectl exec -i deployment/postgres-deployment -n myapp-namespace -- psql -U postgres postgres < backup.sql

# Scale up application
kubectl scale deployment backend-deployment --replicas=3 -n myapp-namespace
```

## Cleanup

To remove all resources:

```bash
./scripts/cleanup.sh
```

This will:
1. Delete all Kubernetes resources
2. Remove static IP addresses
3. Delete Docker images
4. Optionally delete the GKE cluster

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review Kubernetes and GKE documentation
3. Use the monitoring script for real-time debugging
4. Check application logs for detailed error messages

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with Docker Compose
5. Submit a pull request

## License

This project is licensed under the MIT License.
