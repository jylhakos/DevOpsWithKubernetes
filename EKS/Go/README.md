# Amazon EKS deployment for Go application

This directory contains all the necessary files to deploy your Go application to Amazon EKS (Elastic Kubernetes Service).

## Project

```
├── k8s/                          # Kubernetes manifests
│   ├── namespace.yaml            # Namespace definition
│   ├── configmap.yaml           # Configuration data
│   ├── secret.yaml              # Sensitive data (passwords, etc.)
│   ├── deployment.yaml          # Go application deployment
│   ├── postgres.yaml            # PostgreSQL database
│   ├── redis.yaml               # Redis cache
│   ├── ingress.yaml             # Load balancer configuration
│   └── hpa.yaml                 # Horizontal Pod Autoscaler
└── scripts/                     # Deployment scripts
    ├── setup-prerequisites.sh   # Install required tools
    ├── deploy-to-eks.sh         # Main deployment script
    ├── monitor-deployment.sh    # Monitoring and troubleshooting
    └── cleanup.sh               # Resource cleanup
```

## Prerequisites

Before deploying, you need:

1. **AWS account** with appropriate permissions
2. **Domain name** (for ingress)
3. **SSL Certificate** in AWS Certificate Manager
4. **Linux** with bash shell

## Quick start

### 1. Install prerequisites

```bash
chmod +x scripts/setup-prerequisites.sh
./scripts/setup-prerequisites.sh
```

This installs:
- Docker
- AWS CLI v2
- kubectl
- eksctl
- Helm

### 2. Configure AWS credentials

```bash
aws configure
```

Enter your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., `us-west-2`)
- Output format (`json`)

### 3. Update configuration

Edit the following variables in `scripts/deploy-to-eks.sh`:

```bash
AWS_REGION="us-west-2"                    # Your preferred region
AWS_ACCOUNT_ID="123456789012"             # Your AWS account ID
CLUSTER_NAME="go-app-cluster"             # EKS cluster name
ECR_REPOSITORY="go-app"                   # ECR repository name
DOMAIN_NAME="your-domain.com"             # Your domain name
CERTIFICATE_ARN="arn:aws:acm:..."         # Your SSL certificate ARN
```

### 4. Deploy to EKS

```bash
chmod +x scripts/deploy-to-eks.sh
./scripts/deploy-to-eks.sh
```

This script will:
- Create EKS cluster
- Create ECR repository
- Build and push Docker image
- Install AWS Load Balancer Controller
- Deploy all Kubernetes resources
- Configure ingress with SSL

### 5. Monitor

```bash
chmod +x scripts/monitor-deployment.sh
./scripts/monitor-deployment.sh
```

## Kubernetes resources

### Application components

1. **Go Application**: Main web server with 3 replicas
2. **PostgreSQL**: Database with persistent storage
3. **Redis**: Cache server
4. **Ingress**: AWS Application Load Balancer with SSL

### Configuration

- **ConfigMap**: Non-sensitive configuration (ports, hosts)
- **Secret**: Sensitive data (passwords) - **Update before deployment**
- **HPA**: Auto-scaling based on CPU/memory usage (2-10 replicas)

### Networking

- **Services**: ClusterIP services for internal communication
- **Ingress**: Internet-facing load balancer with SSL termination

## Important updates

### 1. Update secrets

Edit `k8s/secret.yaml` with your actual passwords (base64 encoded):

```bash
echo -n "your_postgres_password" | base64
echo -n "your_redis_password" | base64
```

### 2. Update ConfigMap

Edit `k8s/configmap.yaml` with your environment-specific values:

```yaml
data:
  REQUEST_ORIGIN: "https://your-frontend-domain.com"
  POSTGRES_DB: "your_database_name"
  POSTGRES_USER: "your_database_user"
```

### 3. Update Ingress

Edit `k8s/ingress.yaml`:
- Replace `your-domain.com` with your actual domain
- Replace certificate ARN with your SSL certificate

## Accessing your application

After deployment, your application will be available at:
- `https://your-domain.com/ping` - Health check
- `https://your-domain.com/messages` - API endpoints

## Monitoring and troubleshooting

### View resources
```bash
kubectl get all -n go-app
```

### Check logs
```bash
kubectl logs -n go-app -l app=go-app
```

### Port forward (for testing)
```bash
kubectl port-forward svc/go-app-service 8080:80 -n go-app
```

### Scaling
```bash
kubectl scale deployment go-app-deployment --replicas=5 -n go-app
```

## Cost optimization

The default configuration uses:
- **t3.medium** nodes (3 nodes)
- **gp2** storage for PostgreSQL
- **Application Load Balancer**

For production
- Using spot instances
- Implementing cluster autoscaling
- Using RDS for PostgreSQL
- Using ElastiCache for Redis

## Security

1. **Update default passwords** in secrets
2. **Use IAM roles** instead of access keys when possible
3. **Enable logging** and monitoring
4. **Regular security updates** for base images
5. **Network policies** for pod-to-pod communication

## Cleanup

To remove all resources:

```bash
chmod +x scripts/cleanup.sh
./scripts/cleanup.sh
```

**Warning**: This will delete everything including the EKS cluster and data!

## Troubleshooting

### Issues

1. **Pods stuck in Pending**: Check node capacity and resource requests
2. **ImagePullBackOff**: Verify ECR repository and image tag
3. **CrashLoopBackOff**: Check application logs and environment variables
4. **Ingress not working**: Verify domain DNS and certificate ARN

### Commands

```bash
# Check cluster info
kubectl cluster-info

# Check node status
kubectl get nodes

# Describe problematic pods
kubectl describe pod <pod-name> -n go-app

# Check events
kubectl get events -n go-app --sort-by=.metadata.creationTimestamp

# Connect to pod
kubectl exec -it <pod-name> -n go-app -- /bin/sh
```

## Support

For issues:
1. Check the monitoring script output
2. Review Kubernetes events
3. Check AWS CloudWatch logs
4. Verify AWS permissions and quotas
