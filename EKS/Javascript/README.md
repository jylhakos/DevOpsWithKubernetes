# React frontend deployment to Amazon EKS

This guide provides comprehensive instructions for deploying a React frontend application to Amazon EKS using Kubernetes.

## Project

```
├── Dockerfile                 # Container definition for React app
├── docker-compose.yaml        # Local development with Docker Compose
├── package.json              # Node.js dependencies
├── src/                      # React application source code
├── public/                   # Static assets
├── k8s/                      # Kubernetes deployment manifests
│   ├── namespace.yaml        # Kubernetes namespace
│   ├── deployment.yaml       # Deployment and Service
│   ├── configmap.yaml        # Configuration management
│   ├── ingress.yaml          # Application Load Balancer ingress
│   └── hpa.yaml              # Horizontal Pod Autoscaler
├── install-eks-tools.sh      # Tool installation script
└── deploy-to-eks.sh          # Main deployment script
```

## Prerequisites

### Required tools

1. **Docker** - Container runtime
2. **Docker Compose** - Multi-container orchestration
3. **AWS CLI v2** - AWS command line interface
4. **kubectl** - Kubernetes command line tool
5. **eksctl** - Amazon EKS cluster management
6. **Helm** - Kubernetes package manager
7. **Node.js & npm** - JavaScript runtime and package manager

### AWS requirements

1. **AWS account** with appropriate permissions
2. **AWS IAM user** with programmatic access
3. **Required IAM permissions**:
   - EKS cluster management
   - EC2 instances and networking
   - ECR repository access
   - IAM role management
   - Application Load Balancer management

## Installation

### 1. Install required tools

Run the automated installation script:

```bash
./install-eks-tools.sh
```

This script will install all necessary tools on Ubuntu/Debian systems.

### 2. Configure AWS CLI

After installation, configure your AWS credentials:

```bash
aws configure
```

You'll need to provide:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., `us-east-1`)
- Default output format (`json`)

### 3. Verify installation

Check that all tools are properly installed:

```bash
./deploy-to-eks.sh prerequisites
```

## Deployment options

### Option 1: Automated

Deploy everything with a single command:

```bash
./deploy-to-eks.sh deploy
```

This will:
1. Create ECR repository
2. Build and push Docker image
3. Create EKS cluster
4. Install AWS Load Balancer Controller
5. Deploy the application
6. Show deployment status

### Option 2: Step-by-step

For more control, deploy in stages:

```bash
# 1. Build and push Docker image
./deploy-to-eks.sh build

# 2. Create EKS cluster
./deploy-to-eks.sh cluster

# 3. Deploy application
./deploy-to-eks.sh deploy

# 4. Check status
./deploy-to-eks.sh status
```

### Option 3: Local development with Docker Compose

For local development and testing:

```bash
# Build and run locally
docker-compose up --build

# Access application at http://localhost:5000
```

## Kubernetes resources

### 1. Namespace (`k8s/namespace.yaml`)
Creates an isolated environment for the application resources.

### 2. Deployment (`k8s/deployment.yaml`)
- **Replicas**: 3 pods for high availability
- **Resource limits**: Memory and CPU constraints
- **Health checks**: Liveness and readiness probes
- **Environment variables**: Configuration through env vars

### 3. Service (`k8s/deployment.yaml`)
- **Type**: ClusterIP for internal communication
- **Port mapping**: External port 80 → Container port 5000

### 4. ConfigMap (`k8s/configmap.yaml`)
Stores configuration data that can be consumed by pods.

### 5. Ingress (`k8s/ingress.yaml`)
- **AWS Application Load Balancer**: Internet-facing load balancer
- **Health checks**: Automated health monitoring
- **Domain routing**: Routes traffic to the service

### 6. HPA (`k8s/hpa.yaml`)
- **Auto-scaling**: 2-10 pods based on CPU/memory usage
- **Metrics**: CPU (70%) and Memory (80%) thresholds

## Configuration

### Environment variables

Update the following in `k8s/deployment.yaml`:

```yaml
env:
- name: REACT_APP_BACKEND_URL
  value: "http://your-backend-service:8000"
```

### Docker image

Update the image reference in `k8s/deployment.yaml`:

```yaml
image: your-account-id.dkr.ecr.us-east-1.amazonaws.com/react-frontend:latest
```

### Domain configuration

Update the domain in `k8s/ingress.yaml`:

```yaml
rules:
- host: your-domain.com
```

## Monitoring and management

### Check deployment status

```bash
# All resources
./deploy-to-eks.sh status

# Specific resources
kubectl get pods -n react-frontend
kubectl get services -n react-frontend
kubectl get ingress -n react-frontend
```

### View logs

```bash
# Application logs
kubectl logs -f deployment/react-frontend-deployment -n react-frontend

# Multiple pods
kubectl logs -f -l app=react-frontend -n react-frontend
```

### Scaling

```bash
# Manual scaling
kubectl scale deployment react-frontend-deployment --replicas=5 -n react-frontend

# Auto-scaling is handled by HPA
kubectl get hpa -n react-frontend
```

## Troubleshooting

### Issues

1. **Image pull errors**
   - Verify ECR repository exists
   - Check AWS credentials
   - Ensure image was pushed successfully

2. **Pod**
   - Check logs: `kubectl logs <pod-name> -n react-frontend`
   - Verify resource limits
   - Check health probe configurations

3. **Ingress not working**
   - Verify ALB Controller is installed
   - Check ingress annotations
   - Ensure security groups allow traffic

4. **DNS**
   - Verify domain configuration
   - Check Route53 settings
   - Confirm ALB is provisioned

### Debugging

```bash
# Describe resources
kubectl describe deployment react-frontend-deployment -n react-frontend
kubectl describe service react-frontend-service -n react-frontend
kubectl describe ingress react-frontend-ingress -n react-frontend

# Check events
kubectl get events -n react-frontend --sort-by=.metadata.creationTimestamp

# Access pod directly
kubectl exec -it <pod-name> -n react-frontend -- /bin/bash
```

## Security

1. **Network policies**: Implement network segmentation
2. **RBAC**: Role-based access control
3. **Secrets**: Use AWS Secrets Manager or K8s secrets
4. **Image security**: Regular vulnerability scanning
5. **SSL/TLS**: Configure HTTPS with certificates

## Cost Optimization

1. **Right-sizing**: Monitor resource usage and adjust limits
2. **Spot instances**: Use EC2 spot instances for worker nodes
3. **Cluster Autoscaler**: Automatically adjust node count
4. **Resource quotas**: Limit resource usage per namespace

## Cleanup

To remove all resources and avoid ongoing costs:

```bash
./deploy-to-eks.sh cleanup
```

This will:
- Delete Kubernetes resources
- Delete EKS cluster
- Delete ECR repository
- Clean up associated AWS resources

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review AWS EKS documentation
3. Check Kubernetes documentation
4. Review application logs

## Additional Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
