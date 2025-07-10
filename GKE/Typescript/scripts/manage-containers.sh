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

# Show cluster information
show_cluster_info() {
    print_status "Cluster Information:"
    echo "===================="
    gcloud container clusters describe $CLUSTER_NAME --zone=$ZONE --project=$PROJECT_ID
    echo "===================="
}

# Show all resources
show_all_resources() {
    print_status "All Resources in typescript-app namespace:"
    echo "===================="
    kubectl get all -n typescript-app
    echo ""
    echo "ConfigMaps:"
    kubectl get configmaps -n typescript-app
    echo ""
    echo "Secrets:"
    kubectl get secrets -n typescript-app
    echo ""
    echo "Network Policies:"
    kubectl get networkpolicies -n typescript-app
    echo ""
    echo "Service Accounts:"
    kubectl get serviceaccounts -n typescript-app
    echo "===================="
}

# Show logs
show_logs() {
    local app=$1
    local lines=${2:-50}
    
    print_status "Showing logs for $app (last $lines lines):"
    echo "===================="
    kubectl logs -l app=$app -n typescript-app --tail=$lines
    echo "===================="
}

# Show pod details
show_pod_details() {
    local pod=$1
    
    print_status "Pod Details for $pod:"
    echo "===================="
    kubectl describe pod $pod -n typescript-app
    echo "===================="
}

# Show service details
show_service_details() {
    local service=$1
    
    print_status "Service Details for $service:"
    echo "===================="
    kubectl describe service $service -n typescript-app
    echo "===================="
}

# Show events
show_events() {
    print_status "Recent Events:"
    echo "===================="
    kubectl get events -n typescript-app --sort-by=.metadata.creationTimestamp
    echo "===================="
}

# Show resource usage
show_resource_usage() {
    print_status "Resource Usage:"
    echo "===================="
    echo "Pods:"
    kubectl top pods -n typescript-app
    echo ""
    echo "Nodes:"
    kubectl top nodes
    echo "===================="
}

# Port forward to service
port_forward() {
    local service=$1
    local port=$2
    local local_port=${3:-$port}
    
    print_status "Port forwarding $service:$port to localhost:$local_port"
    print_warning "Press Ctrl+C to stop port forwarding"
    
    kubectl port-forward service/$service $local_port:$port -n typescript-app
}

# Execute command in pod
exec_pod() {
    local app=$1
    shift
    local command="$@"
    
    local pod=$(kubectl get pods -l app=$app -n typescript-app -o jsonpath='{.items[0].metadata.name}')
    
    if [ -z "$pod" ]; then
        print_error "No pod found for app: $app"
        exit 1
    fi
    
    print_status "Executing command in pod $pod: $command"
    kubectl exec -it $pod -n typescript-app -- $command
}

# Restart deployment
restart_deployment() {
    local deployment=$1
    
    print_status "Restarting deployment: $deployment"
    kubectl rollout restart deployment/$deployment -n typescript-app
    
    if [ $? -eq 0 ]; then
        print_status "Deployment restarted successfully."
        kubectl rollout status deployment/$deployment -n typescript-app
    else
        print_error "Failed to restart deployment."
        exit 1
    fi
}

# Delete all resources
cleanup() {
    print_warning "This will delete all resources in the typescript-app namespace."
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Deleting all resources..."
        kubectl delete namespace typescript-app
        print_status "All resources deleted."
    else
        print_status "Operation cancelled."
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  cluster-info                     Show cluster information"
    echo "  all                              Show all resources"
    echo "  logs <app> [lines]              Show logs for app (default: 50 lines)"
    echo "  pod-details <pod-name>          Show pod details"
    echo "  service-details <service-name>  Show service details"
    echo "  events                          Show recent events"
    echo "  resources                       Show resource usage"
    echo "  port-forward <service> <port> [local-port]  Port forward to service"
    echo "  exec <app> <command>            Execute command in pod"
    echo "  restart <deployment>            Restart deployment"
    echo "  cleanup                         Delete all resources"
    echo ""
    echo "Examples:"
    echo "  $0 all"
    echo "  $0 logs backend 100"
    echo "  $0 port-forward frontend-service 80 8080"
    echo "  $0 exec backend /bin/sh"
    echo "  $0 restart backend-deployment"
}

# Main function
main() {
    case $1 in
        "cluster-info")
            show_cluster_info
            ;;
        "all")
            show_all_resources
            ;;
        "logs")
            if [ -z "$2" ]; then
                print_error "Please provide app name."
                exit 1
            fi
            show_logs "$2" "$3"
            ;;
        "pod-details")
            if [ -z "$2" ]; then
                print_error "Please provide pod name."
                exit 1
            fi
            show_pod_details "$2"
            ;;
        "service-details")
            if [ -z "$2" ]; then
                print_error "Please provide service name."
                exit 1
            fi
            show_service_details "$2"
            ;;
        "events")
            show_events
            ;;
        "resources")
            show_resource_usage
            ;;
        "port-forward")
            if [ -z "$3" ]; then
                print_error "Please provide service name and port."
                exit 1
            fi
            port_forward "$2" "$3" "$4"
            ;;
        "exec")
            if [ -z "$3" ]; then
                print_error "Please provide app name and command."
                exit 1
            fi
            shift 2
            exec_pod "$1" "$@"
            ;;
        "restart")
            if [ -z "$2" ]; then
                print_error "Please provide deployment name."
                exit 1
            fi
            restart_deployment "$2"
            ;;
        "cleanup")
            cleanup
            ;;
        *)
            show_usage
            ;;
    esac
}

# Run main function
main "$@"
