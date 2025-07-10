# ML application on Google Kubernetes Engine (GKE)

This project deploys a machine learning application consisting of three components to Google Kubernetes Engine.

1. **ml-training**: Python script that downloads images, generates CSV files, and creates a CNN model
2. **ml-backend**: Flask REST API that serves the trained model for image classification (cucumber vs moped)
3. **ml-frontend**: React application that provides a web interface for image uploads

## Architecture

```
Browser → Load Balancer → Frontend (React) → Backend (Flask) → ML Model
                                                ↑
                                         Trained by Training Job
```

## Prerequisites

- Google Cloud Platform account with billing enabled
- `gcloud` CLI installed and configured
- `kubectl` installed
- Docker installed
- Sufficient GCP quotas for GKE resources

## Quick start

1. **Clone and navigate to the project:**
   ```bash
   cd /path/to/ml-app
   ```

2. **Set your GCP project ID:**
   ```bash
   export PROJECT_ID=your-gcp-project-id
   ```

3. **Run the deployment script:**
   ```bash
   ./deploy.sh
   ```

4. **Access the application:**
   The script will output the external IP address where you can access the application.

## Manual deployment

### 1. Setup GCP project

```bash
# Set project
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable storage-api.googleapis.com
gcloud services enable iam.googleapis.com

# Configure Docker
gcloud auth configure-docker
```

### 2. Create GKE Cluster

```bash
gcloud container clusters create ml-app-cluster \
    --zone=us-central1-a \
    --num-nodes=3 \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=5 \
    --enable-autorepair \
    --enable-autoupgrade \
    --machine-type=e2-standard-4 \
    --disk-size=50GB \
    --enable-ip-alias \
    --enable-workload-identity \
    --enable-shielded-nodes
```

### 3. Setup service account and workload identity

```bash
# Create GCP service account
gcloud iam service-accounts create ml-app-gsa \
    --display-name="ML App Service Account"

# Grant permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:ml-app-gsa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

# Configure Workload Identity
gcloud iam service-accounts add-iam-policy-binding \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:$PROJECT_ID.svc.id.goog[ml-app/ml-service-account]" \
    ml-app-gsa@$PROJECT_ID.iam.gserviceaccount.com
```

### 4. Build and push Docker images

```bash
# Build and push all images
docker build -t gcr.io/$PROJECT_ID/ml-training:latest ./ml-training
docker push gcr.io/$PROJECT_ID/ml-training:latest

docker build -t gcr.io/$PROJECT_ID/ml-backend:latest ./ml-backend
docker push gcr.io/$PROJECT_ID/ml-backend:latest

docker build -t gcr.io/$PROJECT_ID/ml-frontend:latest ./ml-frontend
docker push gcr.io/$PROJECT_ID/ml-frontend:latest
```

### 5. Deploy to Kubernetes

```bash
# Update manifests with your project ID
sed -i "s/PROJECT_ID/$PROJECT_ID/g" kubernetes/*.yaml

# Deploy in order
kubectl apply -f kubernetes/00-namespace-rbac.yaml
kubectl apply -f kubernetes/01-storage.yaml
kubectl apply -f kubernetes/02-config.yaml
kubectl apply -f kubernetes/03-training-job.yaml

# Wait for training to complete
kubectl wait --for=condition=complete job/ml-training-job -n ml-app --timeout=1800s

# Deploy applications
kubectl apply -f kubernetes/04-backend.yaml
kubectl apply -f kubernetes/05-frontend.yaml
kubectl apply -f kubernetes/06-ingress.yaml
```

## Configuration

### Environment variables

Key environment variables that can be configured:

- `PROJECT_ID`: Your GCP project ID
- `CLUSTER_NAME`: Name of the GKE cluster
- `ZONE`: GCP zone for the cluster
- `DOMAIN`: Domain name for the application (if using custom domain)

### Storage configuration

The application uses three persistent volumes:

- **model-storage-pvc**: 10Gi for storing the trained ML model
- **training-data-pvc**: 5Gi for training data and CSV files
- **image-data-pvc**: 20Gi for downloaded images

### Security configuration

- Uses Workload Identity for secure access to GCP services
- RBAC configured with minimal required permissions
- Service account with specific roles for ML and storage operations

## Monitoring and troubleshooting

### Check Pod status
```bash
kubectl get pods -n ml-app
```

### View logs
```bash
# Training logs
kubectl logs job/ml-training-job -n ml-app

# Backend logs
kubectl logs deployment/ml-backend -n ml-app

# Frontend logs
kubectl logs deployment/ml-frontend -n ml-app
```

### Check services
```bash
kubectl get services -n ml-app
```

### Get External IP
```bash
kubectl get service ml-frontend-service -n ml-app
```

## Application workflow

1. **Training Phase**: 
   - Kubernetes Job runs the training container
   - Downloads images to `imgs/` folder
   - Generates CSV files in `data/` folder
   - Creates CNN model and saves to `model/` folder

2. **Serving Phase**:
   - Backend loads the trained model from shared storage
   - Frontend serves the web interface
   - Users can upload images for classification

3. **Classification**:
   - Images uploaded through the frontend
   - Backend processes images using the CNN model
   - Returns classification result (cucumber or moped)

## API endpoints

### Backend API (Port 5000)

- `GET /ping`: Health check endpoint
- `POST /kurkkuvaimopo`: Image classification endpoint
  - Accepts multipart form data with image file
  - Returns classification score

### Frontend (Port 3000)

- Web interface for image upload and classification

## Security

- **Workload Identity**: Secure authentication without storing service account keys
- **RBAC**: Role-based access control with minimal permissions
- **Network Policies**: Controlled communication between services
- **Security Headers**: Nginx configured with security headers
- **Health Checks**: Liveness and readiness probes for all services

## Scaling

The application is configured for horizontal scaling:

- **Backend**: 2 replicas with HPA (Horizontal Pod Autoscaler) ready
- **Frontend**: 2 replicas for high availability
- **Cluster**: Autoscaling enabled (1-5 nodes)

## Cost optimization

- Uses `e2-standard-4` instances for good price/performance ratio
- Autoscaling minimizes costs during low usage
- Training job runs once and terminates
- Efficient container images with multi-stage builds

## Cleanup

To remove all resources:

```bash
./cleanup.sh
```

Or manually:

```bash
# Delete Kubernetes resources
kubectl delete namespace ml-app

# Delete GKE cluster
gcloud container clusters delete ml-app-cluster --zone=us-central1-a
```

## Troubleshooting issues

### Training job fails
- Check resource limits and node capacity
- Verify internet connectivity for image downloads
- Check storage permissions

### Backend can't load model
- Ensure training job completed successfully
- Check persistent volume mounting
- Verify model file exists in storage

### Frontend can't connect to backend
- Check service names and ports
- Verify network policies
- Check backend service is running

### Images don't load
- Check container registry permissions
- Verify image names and tags
- Ensure Docker authentication is configured

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review Kubernetes events: `kubectl get events -n ml-app`
3. Check application logs as shown in monitoring section
