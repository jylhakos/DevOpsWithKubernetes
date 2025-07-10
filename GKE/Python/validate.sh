#!/bin/bash

# ML App Validation Script
# This script validates the deployment and tests the application

set -e

PROJECT_ID="${PROJECT_ID:-your-gcp-project-id}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

validate_deployment() {
    print_status "Validating Kubernetes deployment..."
    
    # Check namespace
    if kubectl get namespace ml-app &> /dev/null; then
        print_status "✓ Namespace 'ml-app' exists"
    else
        print_error "✗ Namespace 'ml-app' not found"
        return 1
    fi
    
    # Check training job
    JOB_STATUS=$(kubectl get job ml-training-job -n ml-app -o jsonpath='{.status.conditions[0].type}' 2>/dev/null || echo "NotFound")
    if [[ "$JOB_STATUS" == "Complete" ]]; then
        print_status "✓ Training job completed successfully"
    elif [[ "$JOB_STATUS" == "Failed" ]]; then
        print_error "✗ Training job failed"
        kubectl logs job/ml-training-job -n ml-app --tail=20
        return 1
    else
        print_warning "⚠ Training job status: $JOB_STATUS"
    fi
    
    # Check deployments
    BACKEND_READY=$(kubectl get deployment ml-backend -n ml-app -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    FRONTEND_READY=$(kubectl get deployment ml-frontend -n ml-app -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    
    if [[ "$BACKEND_READY" -gt 0 ]]; then
        print_status "✓ Backend deployment ready ($BACKEND_READY replicas)"
    else
        print_error "✗ Backend deployment not ready"
        return 1
    fi
    
    if [[ "$FRONTEND_READY" -gt 0 ]]; then
        print_status "✓ Frontend deployment ready ($FRONTEND_READY replicas)"
    else
        print_error "✗ Frontend deployment not ready"
        return 1
    fi
    
    # Check services
    BACKEND_IP=$(kubectl get service ml-backend-service -n ml-app -o jsonpath='{.spec.clusterIP}' 2>/dev/null || echo "")
    FRONTEND_IP=$(kubectl get service ml-frontend-service -n ml-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    
    if [[ -n "$BACKEND_IP" ]]; then
        print_status "✓ Backend service available at $BACKEND_IP:5000"
    else
        print_error "✗ Backend service not available"
        return 1
    fi
    
    if [[ -n "$FRONTEND_IP" ]]; then
        print_status "✓ Frontend service available at $FRONTEND_IP:3000"
    else
        print_warning "⚠ Frontend external IP not yet assigned"
    fi
}

test_backend_api() {
    print_status "Testing backend API..."
    
    # Port forward to test backend
    kubectl port-forward service/ml-backend-service 8080:5000 -n ml-app &
    PF_PID=$!
    
    # Wait for port forward to be ready
    sleep 5
    
    # Test ping endpoint
    if curl -f http://localhost:8080/ping &> /dev/null; then
        print_status "✓ Backend ping endpoint working"
    else
        print_error "✗ Backend ping endpoint failed"
        kill $PF_PID 2>/dev/null || true
        return 1
    fi
    
    # Clean up port forward
    kill $PF_PID 2>/dev/null || true
}

show_application_info() {
    print_status "Application Information:"
    echo
    
    # Get external IP
    EXTERNAL_IP=$(kubectl get service ml-frontend-service -n ml-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    
    if [[ -n "$EXTERNAL_IP" ]]; then
        echo "🌐 Application URL: http://$EXTERNAL_IP:3000"
    else
        echo "🌐 Application URL: External IP pending..."
        echo "   Check with: kubectl get service ml-frontend-service -n ml-app"
    fi
    
    echo
    echo "📊 Resource Status:"
    kubectl get pods,services,pvc -n ml-app
    
    echo
    echo "📝 Useful Commands:"
    echo "   View logs: kubectl logs deployment/ml-backend -n ml-app"
    echo "   Scale backend: kubectl scale deployment ml-backend --replicas=3 -n ml-app"
    echo "   Get external IP: kubectl get service ml-frontend-service -n ml-app"
    echo "   Port forward backend: kubectl port-forward service/ml-backend-service 5000:5000 -n ml-app"
    echo "   Port forward frontend: kubectl port-forward service/ml-frontend-service 3000:3000 -n ml-app"
}

main() {
    print_status "Starting ML App validation..."
    
    if validate_deployment; then
        print_status "✓ Deployment validation passed"
    else
        print_error "✗ Deployment validation failed"
        exit 1
    fi
    
    if test_backend_api; then
        print_status "✓ API tests passed"
    else
        print_warning "⚠ API tests failed (backend might still be starting)"
    fi
    
    show_application_info
    
    print_status "Validation completed!"
}

main "$@"
