# TypeScript full-stack application on Amazon EKS

This project demonstrates how to deploy a full-stack TypeScript application (Express backend + React frontend) to Amazon EKS (Elastic Kubernetes Service).

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Load Balancer │    │   EKS Cluster   │    │   ECR Registry  │
│                 │    │                 │    │                 │
│   Frontend      │───▶│   Frontend Pods │    │   Docker Images │
│   Service       │    │   Backend Pods  │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Local development environment** (Linux/macOS)
3. **SSH key pair** for EC2 instances

## Quick start

### 1. Install required tools

```bash
cd scripts
./install-tools.sh
```

This installs:
- AWS CLI v2
- kubectl
- eksctl
- Docker
- jq

### 2. Configure AWS CLI

```bash
aws configure
```

Enter your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., us-west-2)
- Default output format (json)

### 3. Set up IAM Roles

```bash
./setup-iam.sh
```

### 4. Create EKS cluster

```bash
./create-eks-cluster.sh typescript-app-cluster us-west-2
```

This creates:
- EKS cluster with managed node group
- 2-10 t3.medium instances
- Proper networking and security groups

### 5. Build and push Docker images

```bash
# Replace with your AWS account ID
./build-and-push.sh 123456789012 us-west-2
```

### 6. Update Kubernetes manifests

```bash
./update-k8s-images.sh 123456789012 us-west-2
```

### 7. Deployment

```bash
./deploy-to-eks.sh
```

### 8. Get application URL

```bash
kubectl get service frontend-service -n typescript-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## Project

```
├── backend/
│   ├── src/
│   │   └── server.ts          # Express server
│   ├── Dockerfile             # Backend container
│   └── package.json
├── frontend/
│   ├── src/
│   │   ├── App.tsx           # React app
│   │   └── index.tsx
│   ├── Dockerfile            # Frontend container
│   ├── nginx.conf            # Nginx configuration
│   └── package.json
├── k8s/
│   ├── backend-deployment.yaml    # Backend K8s resources
│   ├── frontend-deployment.yaml   # Frontend K8s resources
│   ├── hpa.yaml                  # Horizontal Pod Autoscaler
│   ├── namespace-resources.yaml  # Namespace and resource limits
│   └── network-policy.yaml      # Network security policies
├── scripts/
│   ├── install-tools.sh          # Install AWS tools
│   ├── setup-iam.sh             # Create IAM roles
│   ├── create-eks-cluster.sh     # Create EKS cluster
│   ├── build-and-push.sh        # Build/push Docker images
│   ├── update-k8s-images.sh     # Update K8s manifests
│   ├── deploy-to-eks.sh         # Deploy to EKS
│   └── monitor-and-scale.sh     # Monitoring and scaling
└── README.md
```

## Docker images

### Backend image
- **Base**: node:18-alpine
- **Security**: Non-root user
- **Port**: 5000
- **Health checks**: HTTP probe on /

### Frontend image
- **Multi-stage build**: Node.js + Nginx
- **Base**: nginx:alpine
- **Port**: 80
- **Features**: Gzip compression, security headers

## Kubernetes Resources

### Deployments
- **Backend**: 2 replicas, 128Mi-256Mi memory, 100m-200m CPU
- **Frontend**: 2 replicas, 64Mi-128Mi memory, 50m-100m CPU

### Services
- **Backend**: ClusterIP (internal)
- **Frontend**: LoadBalancer (external)

### Auto-scaling
- **HPA**: CPU 70%, Memory 80%
- **Min replicas**: 2
- **Max replicas**: 10

### Security
- **Network policies**: Restrict pod-to-pod communication
- **Resource limits**: Prevent resource exhaustion
- **Non-root containers**: Enhanced security

## Monitoring and management

### Check status
```bash
./monitor-and-scale.sh status
```

### View logs
```bash
./monitor-and-scale.sh logs backend
./monitor-and-scale.sh logs frontend
```

### Scaling
```bash
./monitor-and-scale.sh scale backend 5
./monitor-and-scale.sh scale frontend 3
```

### Check resources
```bash
./monitor-and-scale.sh resources
```

## Cost optimization

### Resource limits
- **Backend**: 256Mi memory, 200m CPU
- **Frontend**: 128Mi memory, 100m CPU
- **Nodes**: t3.medium instances

### Auto-scaling
- Scales down during low traffic
- Scales up during high traffic
- Minimum 2 replicas for availability

### Monitoring
- CloudWatch metrics
- Kubernetes metrics server
- Resource usage tracking

## Security

### Network security
- VPC isolation
- Security groups
- Network policies

### Container security
- Non-root users
- Minimal base images
- Security headers

### Access control
- IAM roles and policies
- RBAC (Role-Based Access Control)
- Service accounts

## Troubleshooting

### Issues

1. **EKS Cluster creation fails**
   - Check IAM permissions
   - Verify AWS CLI configuration
   - Ensure region availability

2. **Docker push fails**
   - Check ECR login
   - Verify repository exists
   - Check image tagging

3. **Pod startup fails**
   - Check image pull secrets
   - Verify resource limits
   - Check node capacity

### Debugging

```bash
# Check pod status
kubectl get pods -n typescript-app

# Describe pod
kubectl describe pod <pod-name> -n typescript-app

# Check logs
kubectl logs <pod-name> -n typescript-app

# Check events
kubectl get events -n typescript-app
```

## Cleanup

### Delete application
```bash
./monitor-and-scale.sh cleanup
```

### Delete EKS cluster
```bash
eksctl delete cluster --name typescript-app-cluster --region us-west-2
```

### Delete ECR repositories
```bash
aws ecr delete-repository --repository-name typescript-backend --force
aws ecr delete-repository --repository-name typescript-frontend --force
```

## References

- [EKS Documentation](https://docs.aws.amazon.com/eks/)
- [kubectl Documentation](https://kubernetes.io/docs/reference/kubectl/)
- [eksctl Documentation](https://eksctl.io/)
- [Docker Documentation](https://docs.docker.com/)

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review AWS CloudWatch logs
3. Check Kubernetes events
4. Verify IAM permissions
