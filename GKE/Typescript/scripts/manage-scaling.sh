#!/bin/bash

# Configuration
PROJECT_ID=${PROJECT_ID:-"your-gcp-project-id"}
CLUSTER_NAME=${CLUSTER_NAME:-"typescript-cluster"}
ZONE=${ZONE:-"us-central1-a"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Scale deployment
scale_deployment() {
    local deployment=$1
    local replicas=$2
    local namespace=${3:-typescript-app}
    
    print_status "Scaling $deployment to $replicas replicas..."
    
    kubectl scale deployment $deployment --replicas=$replicas -n $namespace
    
    if [ $? -eq 0 ]; then
        print_status "$deployment scaled successfully."
    else
        print_error "Failed to scale $deployment."
        exit 1
    fi
}

# Update HPA settings
update_hpa() {
    local deployment=$1
    local min_replicas=$2
    local max_replicas=$3
    local cpu_target=$4
    local namespace=${5:-typescript-app}
    
    print_status "Updating HPA for $deployment..."
    
    kubectl patch hpa ${deployment}-hpa -n $namespace --type merge -p "{\"spec\":{\"minReplicas\":$min_replicas,\"maxReplicas\":$max_replicas,\"metrics\":[{\"type\":\"Resource\",\"resource\":{\"name\":\"cpu\",\"target\":{\"type\":\"Utilization\",\"averageUtilization\":$cpu_target}}}]}}"
    
    if [ $? -eq 0 ]; then
        print_status "HPA updated successfully."
    else
        print_error "Failed to update HPA."
        exit 1
    fi
}

# Update resource limits
update_resources() {
    local deployment=$1
    local container=$2
    local cpu_request=$3
    local memory_request=$4
    local cpu_limit=$5
    local memory_limit=$6
    local namespace=${7:-typescript-app}
    
    print_status "Updating resource limits for $deployment..."
    
    kubectl patch deployment $deployment -n $namespace --type json -p="[{\"op\": \"replace\", \"path\": \"/spec/template/spec/containers/0/resources\", \"value\": {\"requests\": {\"cpu\": \"$cpu_request\", \"memory\": \"$memory_request\"}, \"limits\": {\"cpu\": \"$cpu_limit\", \"memory\": \"$memory_limit\"}}}]"
    
    if [ $? -eq 0 ]; then
        print_status "Resource limits updated successfully."
    else
        print_error "Failed to update resource limits."
        exit 1
    fi
}

# Show current status
show_status() {
    print_status "Current Status:"
    echo "===================="
    echo "Deployments:"
    kubectl get deployments -n typescript-app
    echo ""
    echo "HPA Status:"
    kubectl get hpa -n typescript-app
    echo ""
    echo "Pod Status:"
    kubectl get pods -n typescript-app
    echo ""
    echo "Resource Usage:"
    kubectl top pods -n typescript-app
    echo "===================="
}

# Show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  scale-backend <replicas>         Scale backend deployment"
    echo "  scale-frontend <replicas>        Scale frontend deployment"
    echo "  update-backend-hpa <min> <max> <cpu_target>  Update backend HPA"
    echo "  update-frontend-hpa <min> <max> <cpu_target> Update frontend HPA"
    echo "  update-backend-resources <cpu_req> <mem_req> <cpu_limit> <mem_limit>"
    echo "  update-frontend-resources <cpu_req> <mem_req> <cpu_limit> <mem_limit>"
    echo "  status                           Show current status"
    echo "  monitor                          Monitor resources in real-time"
    echo ""
    echo "Examples:"
    echo "  $0 scale-backend 5"
    echo "  $0 update-backend-hpa 3 15 80"
    echo "  $0 update-backend-resources 200m 256Mi 500m 512Mi"
    echo "  $0 status"
}

# Monitor resources
monitor_resources() {
    print_status "Monitoring resources (Press Ctrl+C to stop)..."
    
    while true; do
        clear
        echo "=== Resource Monitoring ==="
        echo "Timestamp: $(date)"
        echo ""
        echo "HPA Status:"
        kubectl get hpa -n typescript-app
        echo ""
        echo "Pod Resource Usage:"
        kubectl top pods -n typescript-app
        echo ""
        echo "Node Resource Usage:"
        kubectl top nodes
        echo ""
        sleep 10
    done
}

# Main function
main() {
    case $1 in
        "scale-backend")
            if [ -z "$2" ]; then
                print_error "Please provide number of replicas."
                exit 1
            fi
            scale_deployment "backend-deployment" "$2"
            ;;
        "scale-frontend")
            if [ -z "$2" ]; then
                print_error "Please provide number of replicas."
                exit 1
            fi
            scale_deployment "frontend-deployment" "$2"
            ;;
        "update-backend-hpa")
            if [ -z "$4" ]; then
                print_error "Please provide min replicas, max replicas, and CPU target."
                exit 1
            fi
            update_hpa "backend-deployment" "$2" "$3" "$4"
            ;;
        "update-frontend-hpa")
            if [ -z "$4" ]; then
                print_error "Please provide min replicas, max replicas, and CPU target."
                exit 1
            fi
            update_hpa "frontend-deployment" "$2" "$3" "$4"
            ;;
        "update-backend-resources")
            if [ -z "$5" ]; then
                print_error "Please provide CPU request, memory request, CPU limit, and memory limit."
                exit 1
            fi
            update_resources "backend-deployment" "backend" "$2" "$3" "$4" "$5"
            ;;
        "update-frontend-resources")
            if [ -z "$5" ]; then
                print_error "Please provide CPU request, memory request, CPU limit, and memory limit."
                exit 1
            fi
            update_resources "frontend-deployment" "frontend" "$2" "$3" "$4" "$5"
            ;;
        "status")
            show_status
            ;;
        "monitor")
            monitor_resources
            ;;
        *)
            show_usage
            ;;
    esac
}

# Run main function
main "$@"
