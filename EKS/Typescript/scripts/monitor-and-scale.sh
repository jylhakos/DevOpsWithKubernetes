#!/bin/bash

# Script for monitoring and scaling operations
# Usage: ./monitor-and-scale.sh [command] [args...]

set -e

NAMESPACE="typescript-app"

case "$1" in
    "status")
        echo "=== Cluster Status ==="
        kubectl get nodes
        echo ""
        echo "=== Pod Status ==="
        kubectl get pods -n $NAMESPACE
        echo ""
        echo "=== Service Status ==="
        kubectl get services -n $NAMESPACE
        echo ""
        echo "=== HPA Status ==="
        kubectl get hpa -n $NAMESPACE
        ;;
    
    "logs")
        SERVICE=${2:-"backend"}
        echo "=== Logs for $SERVICE ==="
        kubectl logs -f deployment/${SERVICE}-deployment -n $NAMESPACE
        ;;
    
    "scale")
        SERVICE=${2:-"backend"}
        REPLICAS=${3:-"3"}
        echo "Scaling $SERVICE to $REPLICAS replicas..."
        kubectl scale deployment/${SERVICE}-deployment --replicas=$REPLICAS -n $NAMESPACE
        echo "Waiting for scaling to complete..."
        kubectl wait --for=condition=available --timeout=300s deployment/${SERVICE}-deployment -n $NAMESPACE
        echo "Scaling completed!"
        ;;
    
    "resources")
        echo "=== Resource Usage ==="
        kubectl top nodes
        echo ""
        kubectl top pods -n $NAMESPACE
        ;;
    
    "describe")
        SERVICE=${2:-"backend"}
        echo "=== Describing $SERVICE deployment ==="
        kubectl describe deployment/${SERVICE}-deployment -n $NAMESPACE
        ;;
    
    "events")
        echo "=== Recent Events ==="
        kubectl get events -n $NAMESPACE --sort-by=.metadata.creationTimestamp
        ;;
    
    "health")
        echo "=== Health Check ==="
        kubectl get pods -n $NAMESPACE -o wide
        echo ""
        echo "=== Service Endpoints ==="
        kubectl get endpoints -n $NAMESPACE
        ;;
    
    "cleanup")
        echo "=== Cleaning up resources ==="
        kubectl delete namespace $NAMESPACE
        echo "Namespace $NAMESPACE deleted!"
        ;;
    
    *)
        echo "Usage: $0 [command] [args...]"
        echo ""
        echo "Commands:"
        echo "  status              - Show cluster and pod status"
        echo "  logs [service]      - Show logs for service (backend/frontend)"
        echo "  scale [service] [n] - Scale service to n replicas"
        echo "  resources           - Show resource usage"
        echo "  describe [service]  - Describe deployment"
        echo "  events              - Show recent events"
        echo "  health              - Show health status"
        echo "  cleanup             - Delete all resources"
        echo ""
        echo "Examples:"
        echo "  $0 status"
        echo "  $0 logs backend"
        echo "  $0 scale frontend 5"
        echo "  $0 resources"
        ;;
esac
