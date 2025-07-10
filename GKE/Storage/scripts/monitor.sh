#!/bin/bash

# Monitoring and maintenance script for GKE deployment
# This script provides various monitoring and maintenance functions

set -e

PROJECT_ID="your-gcp-project-id"
CLUSTER_NAME="myapp-cluster"
ZONE="us-central1-a"
NAMESPACE="myapp-namespace"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Function to show cluster status
show_cluster_status() {
    print_header "Cluster Status"
    
    echo ""
    print_status "Cluster Info:"
    gcloud container clusters describe $CLUSTER_NAME --zone=$ZONE --format="table(name,status,currentNodeCount,location)"
    
    echo ""
    print_status "Node Status:"
    kubectl get nodes -o wide
    
    echo ""
    print_status "Namespace Status:"
    kubectl get all -n $NAMESPACE
}

# Function to show application health
show_app_health() {
    print_header "Application Health"
    
    echo ""
    print_status "Pod Status:"
    kubectl get pods -n $NAMESPACE -o wide
    
    echo ""
    print_status "Service Status:"
    kubectl get svc -n $NAMESPACE
    
    echo ""
    print_status "Ingress Status:"
    kubectl get ingress -n $NAMESPACE
    
    echo ""
    print_status "HPA Status:"
    kubectl get hpa -n $NAMESPACE
    
    echo ""
    print_status "PVC Status:"
    kubectl get pvc -n $NAMESPACE
}

# Function to show resource usage
show_resource_usage() {
    print_header "Resource Usage"
    
    echo ""
    print_status "Node Resource Usage:"
    kubectl top nodes
    
    echo ""
    print_status "Pod Resource Usage:"
    kubectl top pods -n $NAMESPACE
    
    echo ""
    print_status "Cluster Resource Quotas:"
    kubectl describe quota -n $NAMESPACE
}

# Function to show logs
show_logs() {
    print_header "Recent Logs"
    
    echo ""
    print_status "Backend Logs (last 50 lines):"
    kubectl logs -n $NAMESPACE -l app=backend --tail=50
    
    echo ""
    print_status "Frontend Logs (last 50 lines):"
    kubectl logs -n $NAMESPACE -l app=frontend --tail=50
    
    echo ""
    print_status "Redis Logs (last 20 lines):"
    kubectl logs -n $NAMESPACE -l app=redis --tail=20
    
    echo ""
    print_status "PostgreSQL Logs (last 20 lines):"
    kubectl logs -n $NAMESPACE -l app=postgres --tail=20
}

# Function to test endpoints
test_endpoints() {
    print_header "Endpoint Testing"
    
    # Get ingress IPs
    BACKEND_IP=$(gcloud compute addresses describe backend-ip --global --format='value(address)' 2>/dev/null || echo "Not found")
    FRONTEND_IP=$(gcloud compute addresses describe frontend-ip --global --format='value(address)' 2>/dev/null || echo "Not found")
    
    echo ""
    print_status "External IP Addresses:"
    echo "Backend IP: $BACKEND_IP"
    echo "Frontend IP: $FRONTEND_IP"
    
    echo ""
    print_status "Testing Backend Health:"
    if [ "$BACKEND_IP" != "Not found" ]; then
        echo "Testing basic ping..."
        curl -s -o /dev/null -w "%{http_code}" http://$BACKEND_IP/ping || echo "Failed"
        
        echo ""
        echo "Testing Redis connection..."
        curl -s -o /dev/null -w "%{http_code}" http://$BACKEND_IP/ping?redis=true || echo "Failed"
        
        echo ""
        echo "Testing PostgreSQL connection..."
        curl -s -o /dev/null -w "%{http_code}" http://$BACKEND_IP/ping?postgres=true || echo "Failed"
    else
        print_warning "Backend IP not available for testing"
    fi
}

# Function to scale deployments
scale_deployments() {
    print_header "Scaling Deployments"
    
    echo "Current replica counts:"
    kubectl get deployments -n $NAMESPACE -o custom-columns=NAME:.metadata.name,REPLICAS:.spec.replicas,AVAILABLE:.status.availableReplicas
    
    echo ""
    echo "Enter new replica count for backend (current: $(kubectl get deployment backend-deployment -n $NAMESPACE -o jsonpath='{.spec.replicas}')):"
    read -r backend_replicas
    
    echo "Enter new replica count for frontend (current: $(kubectl get deployment frontend-deployment -n $NAMESPACE -o jsonpath='{.spec.replicas}')):"
    read -r frontend_replicas
    
    if [[ "$backend_replicas" =~ ^[0-9]+$ ]]; then
        kubectl scale deployment backend-deployment --replicas=$backend_replicas -n $NAMESPACE
        print_status "Backend scaled to $backend_replicas replicas"
    fi
    
    if [[ "$frontend_replicas" =~ ^[0-9]+$ ]]; then
        kubectl scale deployment frontend-deployment --replicas=$frontend_replicas -n $NAMESPACE
        print_status "Frontend scaled to $frontend_replicas replicas"
    fi
}

# Function to update images
update_images() {
    print_header "Updating Images"
    
    echo "This will rebuild and deploy new images. Continue? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Building and pushing new images..."
        
        # Configure Docker
        gcloud auth configure-docker
        
        # Build and push backend
        cd backend
        docker build -t gcr.io/$PROJECT_ID/backend:latest .
        docker push gcr.io/$PROJECT_ID/backend:latest
        cd ..
        
        # Build and push frontend
        cd frontend
        docker build -t gcr.io/$PROJECT_ID/frontend:latest .
        docker push gcr.io/$PROJECT_ID/frontend:latest
        cd ..
        
        # Restart deployments to pull new images
        kubectl rollout restart deployment/backend-deployment -n $NAMESPACE
        kubectl rollout restart deployment/frontend-deployment -n $NAMESPACE
        
        print_status "Images updated and deployments restarted"
    fi
}

# Function to backup database
backup_database() {
    print_header "Database Backup"
    
    BACKUP_FILE="postgres-backup-$(date +%Y%m%d-%H%M%S).sql"
    
    print_status "Creating database backup..."
    kubectl exec -n $NAMESPACE -it $(kubectl get pods -n $NAMESPACE -l app=postgres -o jsonpath='{.items[0].metadata.name}') -- pg_dump -U postgres postgres > $BACKUP_FILE
    
    print_status "Backup created: $BACKUP_FILE"
}

# Function to show menu
show_menu() {
    echo ""
    print_header "GKE Monitoring & Maintenance Menu"
    echo "1. Show cluster status"
    echo "2. Show application health"
    echo "3. Show resource usage"
    echo "4. Show logs"
    echo "5. Test endpoints"
    echo "6. Scale deployments"
    echo "7. Update images"
    echo "8. Backup database"
    echo "9. Exit"
    echo ""
    echo -n "Choose an option [1-9]: "
}

# Main function
main() {
    if [ "$PROJECT_ID" = "your-gcp-project-id" ]; then
        print_error "Please update the PROJECT_ID in this script before running"
        exit 1
    fi
    
    # Set project and get credentials
    gcloud config set project $PROJECT_ID
    gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE
    
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1) show_cluster_status ;;
            2) show_app_health ;;
            3) show_resource_usage ;;
            4) show_logs ;;
            5) test_endpoints ;;
            6) scale_deployments ;;
            7) update_images ;;
            8) backup_database ;;
            9) print_status "Goodbye!"; exit 0 ;;
            *) print_error "Invalid option. Please choose 1-9." ;;
        esac
        
        echo ""
        echo "Press Enter to continue..."
        read -r
    done
}

main "$@"
