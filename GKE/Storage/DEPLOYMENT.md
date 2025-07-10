# GKE deployment

## 🚀 Setup

This comprehensive setup provides everything needed to deploy your Go backend and React frontend application to Google Kubernetes Engine (GKE) with enterprise-grade features.

## 📁 Project

```
.
├── backend/                    # Go application
│   ├── app.go                 # Main server
│   ├── Dockerfile             # Production-ready container
│   ├── router/                # HTTP routing
│   ├── controller/            # API handlers
│   ├── cache/                 # Redis integration
│   └── pgconnection/          # PostgreSQL integration
├── frontend/                  # React application
│   ├── src/                   # React components
│   ├── Dockerfile             # Optimized container
│   └── package.json           # Dependencies
├── k8s/                       # Kubernetes manifests
│   ├── namespace.yaml         # Isolated namespace
│   ├── configmap.yaml         # Configuration management
│   ├── security.yaml          # RBAC + Network policies
│   ├── postgres.yaml          # Database deployment
│   ├── redis.yaml             # Cache deployment
│   ├── backend.yaml           # API deployment + ingress
│   ├── frontend.yaml          # Web app deployment + ingress
│   └── scaling.yaml           # Auto-scaling configuration
├── scripts/                   # Automation scripts
│   ├── setup.sh              # Install tools (Docker, gcloud, kubectl)
│   ├── deploy.sh              # Complete deployment automation
│   ├── monitor.sh             # Operations dashboard
│   └── cleanup.sh             # Resource cleanup
├── docker-compose.yml         # Local development
└── README.md                  # Comprehensive documentation
```

## 🔧 Key features

### 1. **Container Orchestration**
- **Multi-stage Docker builds** for optimized images
- **Non-root containers** for security
- **Health checks** for all services
- **Resource limits** and requests

### 2. **Kubernetes Configuration**
- **Namespace isolation** (myapp-namespace)
- **Secret management** for sensitive data
- **ConfigMaps** for application configuration
- **Persistent storage** for PostgreSQL
- **Service discovery** between components

### 3. **Security Features**
- **RBAC (Role-Based Access Control)**
- **Network policies** for traffic restriction
- **Security contexts** with non-root users
- **Pod security standards**
- **Managed SSL certificates**

### 4. **High Availability & Scaling**
- **Horizontal Pod Autoscaler (HPA)**
  - CPU-based scaling (70% threshold)
  - Memory-based scaling (80% threshold)
  - Min replicas: 3, Max replicas: 10
- **Pod Disruption Budgets (PDB)**
- **Multi-zone deployment**
- **Rolling updates** with zero downtime

### 5. **Load Balancing & Networking**
- **Google Cloud Load Balancer**
- **Ingress controllers** with SSL termination
- **Static IP reservations**
- **Internal service communication**

### 6. **Storage Management**
- **Persistent Volume Claims (PVC)** for PostgreSQL
- **Google Cloud Storage** integration
- **Automated backup capabilities**
- **Volume mounting** for data persistence

### 7. **Monitoring & Observability**
- **Liveness and readiness probes**
- **Resource usage monitoring**
- **Centralized logging**
- **Health check endpoints**

## 🎯 API endpoints

Your backend provides these endpoints:

| Endpoint | Method | Description | Example |
|----------|--------|-------------|---------|
| `/ping` | GET | Basic health check | `curl https://api.yourapp.com/ping` |
| `/ping?redis=true` | GET | Test Redis connectivity | `curl https://api.yourapp.com/ping?redis=true` |
| `/ping?postgres=true` | GET | Test PostgreSQL connectivity | `curl https://api.yourapp.com/ping?postgres=true` |
| `/messages` | GET | Retrieve messages | `curl https://api.yourapp.com/messages` |
| `/messages` | POST | Create new message | `curl -X POST https://api.yourapp.com/messages` |

## 🚀 Quick deployment

### Step 1: Initial setup
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Install required tools
./scripts/setup.sh
```

### Step 2: Configure GCP
```bash
# Login to Google Cloud
gcloud auth login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Edit deployment configuration
nano scripts/deploy.sh
# Update PROJECT_ID, CLUSTER_NAME, ZONE
```

### Step 3: Deployment
```bash
# Run complete deployment
./scripts/deploy.sh
```

### Step 4: Monitor & manage
```bash
# Interactive monitoring dashboard
./scripts/monitor.sh
```

## 💰 Cost optimization

### Resources
- **Optimized container images** (multi-stage builds)
- **Resource limits** prevent over-provisioning
- **Auto-scaling** adjusts to demand
- **Preemptible nodes** option for cost savings

### Resource allocation
```yaml
Backend:  250m-500m CPU, 256Mi-512Mi Memory
Frontend: 100m-200m CPU, 128Mi-256Mi Memory  
Redis:    100m-200m CPU, 128Mi-256Mi Memory
PostgreSQL: 250m-500m CPU, 256Mi-512Mi Memory
```

## 🔒 Security

### Network security
- **Network policies** restrict pod communication
- **Ingress controllers** handle external traffic
- **TLS/SSL termination** at load balancer
- **Private Google Kubernetes Engine** option

### Access control
- **Service accounts** with minimal permissions
- **RBAC policies** for fine-grained access
- **Namespace isolation** for resource separation
- **Secret management** for sensitive data

### Container security
- **Non-root users** in all containers
- **Read-only root filesystems** where possible
- **Security contexts** with dropped capabilities
- **Regular base image updates**

## 📊 Monitoring & operations

### Health monitoring
- **Application health checks** (`/ping` endpoints)
- **Infrastructure monitoring** (CPU, memory, disk)
- **Service mesh** observability (optional)
- **Log aggregation** with Google Cloud Logging

### Operational tasks
```bash
# Scale applications
kubectl scale deployment backend-deployment --replicas=5 -n myapp-namespace

# Update images
kubectl set image deployment/backend-deployment backend=gcr.io/PROJECT/backend:v2

# Check logs
kubectl logs -f deployment/backend-deployment -n myapp-namespace

# Database backup
kubectl exec -it deployment/postgres-deployment -- pg_dump -U postgres postgres > backup.sql
```

## 🔄 CI/CD

### Build pipeline
1. **Code commit** triggers build
2. **Docker images** built and pushed to GCR
3. **Kubernetes manifests** updated
4. **Rolling deployment** to GKE
5. **Health checks** verify deployment

### Tools
- **Google Cloud Build** for CI/CD
- **GitHub Actions** for automation
- **ArgoCD** for GitOps deployment
- **Helm** for package management

## 🌐 Production Considerations

### Domain configuration
1. **Purchase domains** for frontend and backend
2. **Update DNS** to point to reserved IPs
3. **Configure SSL certificates** in manifests
4. **Update CORS settings** in backend

### Environment variables
```bash
# Development
REQUEST_ORIGIN=http://localhost:5000
REACT_APP_BACKEND_URL=http://localhost:8000

# Production
REQUEST_ORIGIN=https://app.yourdomain.com
REACT_APP_BACKEND_URL=https://api.yourdomain.com
```

## 🚨 Disaster recovery

### Backup
- **Database backups** (automated daily)
- **Configuration backups** (Git repository)
- **Container image backups** (Google Container Registry)
- **Persistent volume snapshots**

### Recovery pProcedures
1. **Cluster recreation** from infrastructure as code
2. **Database restoration** from latest backup
3. **Application redeployment** from saved manifests
4. **DNS updates** if IP addresses change

## 📈 Scaling

### Traffic patterns
- **Low traffic**: 3 replicas (minimum)
- **Medium traffic**: 5-7 replicas (auto-scaled)
- **High traffic**: 8-10 replicas (maximum)
- **Peak events**: Manual scaling or cluster expansion

### Performance tuning
- **Database connection pooling**
- **Redis memory optimization**
- **CDN integration** for static assets
- **Caching strategies** for API responses

## 🎓 References

### Kubernetes
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/docs)

### Google Cloud Platform
- [GCP Documentation](https://cloud.google.com/docs)
- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)

### Application development
- [Go Best Practices](https://golang.org/doc/effective_go.html)
- [React Documentation](https://reactjs.org/docs)

## 📞 Support & troubleshooting

### Common Commands
```bash
# Check cluster status
kubectl cluster-info

# View all resources
kubectl get all -n myapp-namespace

# Debug pod issues
kubectl describe pod POD_NAME -n myapp-namespace

# Access pod shell
kubectl exec -it POD_NAME -n myapp-namespace -- /bin/sh

# Port forwarding for local access
kubectl port-forward service/backend-service 8080:8080 -n myapp-namespace
```

### Troubleshooting
1. ✅ **Images built and pushed** to Container Registry
2. ✅ **Cluster credentials** configured locally
3. ✅ **Static IPs** reserved and configured
4. ✅ **DNS records** pointing to correct IPs
5. ✅ **SSL certificates** provisioned and valid
6. ✅ **Network policies** allow required traffic
7. ✅ **Resource quotas** sufficient for workload

## 🎉 Success metrics

After successful deployment, you should see:
- ✅ All pods running and ready
- ✅ Services accessible via load balancer
- ✅ Health checks passing
- ✅ Auto-scaling responding to load
- ✅ SSL certificates valid
- ✅ Database connectivity working
- ✅ Redis caching functional

## 🔄 Next steps

1. **Configure monitoring** with Prometheus/Grafana
2. **Set up alerts** for critical events
3. **Implement CI/CD pipeline** for automated deployments
4. **Add caching layers** for improved performance
5. **Consider service mesh** for advanced networking
6. **Implement database migrations** for schema changes
7. **Add comprehensive testing** suite
8. **Document API** with OpenAPI/Swagger

This setup provides a production-ready foundation that can scale with your application needs while maintaining security, reliability, and cost-effectiveness.
