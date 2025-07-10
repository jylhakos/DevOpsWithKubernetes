# EKS deployment

This document provides step-by-step instructions to deploy your Go backend and React frontend applications on Amazon EKS with Redis cache and PostgreSQL database.

## Architecture

```
Internet → ALB → EKS Cluster
                    ├── Frontend (React) → Backend (Go)
                    ├── Backend → Redis Cache
                    ├── Backend → PostgreSQL Database
                    └── Persistent Storage (EBS)
```

![alt text](https://github.com/jylhakos/DevOpsWithKubernetes/blob/main/EKS/Storage/architecture.png)

## Prerequisites

- Linux system (Ubuntu/Debian preferred)
- AWS Account with appropriate permissions
- Domain name (optional, for production setup)

## Step 1: Install required tools

Run the installation script to install all necessary tools:

```bash
./scripts/install-tools.sh
```

This installs:
- Docker
- AWS CLI v2
- kubectl
- eksctl
- Helm
- Git
- jq

**Important**: After installation, log out and log back in for Docker group changes to take effect.

## Step 2: Configure AWS credentials

Configure your AWS credentials:

```bash
aws configure
```

Provide:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., us-west-2)
- Default output format (json)

## Step 3: Create EKS cluster

Run the cluster setup script:

```bash
./scripts/setup-cluster.sh
```

This will:
- Create EKS cluster with worker nodes
- Install AWS Load Balancer Controller
- Install EFS CSI Driver
- Create ECR repositories
- Set up storage classes
- Create ConfigMaps and Secrets

## Step 4: Build and push Docker images

Build your applications and push to ECR:

```bash
./scripts/build-and-push.sh
```

This will:
- Build Docker images for backend and frontend
- Push images to ECR
- Update deployment files with correct image URLs

## Step 5: Deployment

Deploy all applications to the cluster:

```bash
./scripts/deploy-apps.sh
```

This deploys:
- PostgreSQL database with persistent storage
- Redis cache with persistent storage
- Go backend application
- React frontend application
- Load balancer and ingress

## Step 6: Configure domain (Optional)

If you have a domain, update the ingress configuration:

1. Edit `k8s/ingress/ingress.yaml`
2. Replace `your-domain.com` with your actual domain
3. Replace `api.your-domain.com` with your API subdomain
4. Update certificate ARN if using SSL/TLS
5. Apply changes: `kubectl apply -f k8s/ingress/ingress.yaml`

## Step 7: Test the application

Get the load balancer URL:

```bash
kubectl get ingress app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Test the endpoints:

```bash
# Test backend ping
curl http://YOUR_ALB_URL/ping

# Test backend with Redis
curl http://YOUR_ALB_URL/ping?redis=true

# Test backend with PostgreSQL
curl http://YOUR_ALB_URL/ping?postgres=true
```

## Monitoring and management

### Check Pod status
```bash
kubectl get pods
kubectl get services
kubectl get ingress
```

### View logs
```bash
# Backend logs
kubectl logs -l app=backend -f

# Frontend logs
kubectl logs -l app=frontend -f

# Database logs
kubectl logs -l app=postgres -f

# Redis logs
kubectl logs -l app=redis -f
```

### Scaling
```bash
# Scale backend
kubectl scale deployment backend-deployment --replicas=5

# Scale frontend
kubectl scale deployment frontend-deployment --replicas=3
```

### Resources
```bash
# Check resource usage
kubectl top pods
kubectl top nodes

# Check resource quotas
kubectl describe resourcequota app-resource-quota
```

## Security

- **Network policies**: Restrict traffic between pods
- **Resource quotas**: Limit resource usage
- **Pod security**: Security contexts for containers
- **Secrets**: Encrypted secrets for sensitive data
- **IAM roles**: Least privilege access for services

## High availability

- **Auto Scaling**: HPA for automatic scaling based on CPU/memory
- **Pod Disruption Budgets**: Ensure minimum replicas during updates
- **Multi-AZ Deployment**: Distributed across availability zones
- **Load Balancing**: ALB distributes traffic across instances
- **Health Checks**: Liveness and readiness probes

## Storage configuration

- **Persistent Volumes**: EBS volumes for database storage
- **Storage Classes**: Different storage types (gp3, io1, efs)
- **Backup Strategy**: EBS snapshots and database backups
- **Encryption**: Storage encryption at rest

## Cost optimization

- **Instance Types**: Right-sized EC2 instances
- **Storage Optimization**: Appropriate storage types
- **Auto Scaling**: Scale down during low usage
- **Spot Instances**: Use spot instances for non-critical workloads

## Troubleshooting

### Issues

1. **Pods not starting**: Check resource limits and node capacity
2. **Load balancer not accessible**: Verify security groups and subnets
3. **Database connection issues**: Check service names and passwords
4. **Image pull errors**: Verify ECR permissions and image URLs

### Debugging

```bash
# Describe resources
kubectl describe pod POD_NAME
kubectl describe service SERVICE_NAME
kubectl describe ingress INGRESS_NAME

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check node status
kubectl get nodes -o wide
kubectl describe node NODE_NAME
```

## Cleanup

To delete all resources:

```bash
./scripts/cleanup.sh
```

This removes:
- All Kubernetes resources
- EKS cluster
- Associated AWS resources

**Note**: Some resources like Load Balancers and EBS volumes may need manual cleanup.

## File structure

```
├── k8s/
│   ├── cluster/
│   │   └── cluster-config.yaml          # EKS cluster configuration
│   ├── deployments/
│   │   ├── backend-deployment.yaml      # Go backend deployment
│   │   ├── frontend-deployment.yaml     # React frontend deployment
│   │   ├── postgres-deployment.yaml     # PostgreSQL deployment
│   │   └── redis-deployment.yaml        # Redis deployment
│   ├── services/
│   │   └── services.yaml                # All service definitions
│   ├── storage/
│   │   ├── storage-class.yaml           # Storage class definitions
│   │   └── postgres-pvc.yaml            # Persistent volume claims
│   ├── ingress/
│   │   └── ingress.yaml                 # ALB ingress and network policies
│   ├── configmaps/
│   │   └── app-config.yaml              # Application configuration
│   └── monitoring/
│       ├── resource-management.yaml     # Resource quotas and HPA
│       └── prometheus-config.yaml       # Monitoring configuration
├── scripts/
│   ├── install-tools.sh                 # Install required tools
│   ├── setup-cluster.sh                 # Create EKS cluster
│   ├── build-and-push.sh                # Build and push images
│   ├── deploy-apps.sh                   # Deploy applications
│   └── cleanup.sh                       # Cleanup resources
├── backend/
│   └── Dockerfile                       # Go application Dockerfile
├── frontend/
│   └── Dockerfile                       # React application Dockerfile
└── docker-compose.yml                   # Local development setup
```

## Best practices

1. **Use namespaces** for different environments
2. **Implement proper logging** and monitoring
3. **Use secrets** for sensitive data
4. **Regular backups** of persistent data
5. **Update images** regularly for security patches
6. **Use resource limits** to prevent resource exhaustion
7. **Implement proper RBAC** for access control

## Support

For issues and troubleshooting:
1. Check Kubernetes events: `kubectl get events`
2. Review pod logs: `kubectl logs -l app=APP_NAME`
3. Verify AWS resources in the console
4. Check eksctl logs for cluster issues

---

This deployment setup provides a production-ready Kubernetes environment on AWS EKS with proper security, scalability, and monitoring capabilities.
