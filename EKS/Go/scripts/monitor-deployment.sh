#!/bin/bash

# Monitoring and troubleshooting script for EKS deployment
# This script helps monitor and troubleshoot the deployed application

set -e

# Configuration
NAMESPACE="go-app"
CLUSTER_NAME="go-app-cluster"
AWS_REGION="us-west-2"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Show cluster information
show_cluster_info() {
    echo -e "${GREEN}=== EKS Cluster Information ===${NC}"
    echo "Cluster Name: $CLUSTER_NAME"
    echo "Region: $AWS_REGION"
    echo "Namespace: $NAMESPACE"
    echo ""
    
    echo -e "${YELLOW}Cluster Status:${NC}"
    aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint}' --output table
}

# Show all resources in the namespace
show_all_resources() {
    echo -e "${GREEN}=== All Resources in Namespace ===${NC}"
    kubectl get all -n $NAMESPACE -o wide
}

# Show pod status and logs
show_pod_status() {
    echo -e "${GREEN}=== Pod Status ===${NC}"
    kubectl get pods -n $NAMESPACE -o wide
    
    echo -e "${GREEN}=== Pod Descriptions ===${NC}"
    kubectl describe pods -n $NAMESPACE
}

# Show service information
show_services() {
    echo -e "${GREEN}=== Services ===${NC}"
    kubectl get svc -n $NAMESPACE -o wide
    
    echo -e "${GREEN}=== Service Descriptions ===${NC}"
    kubectl describe svc -n $NAMESPACE
}

# Show ingress information
show_ingress() {
    echo -e "${GREEN}=== Ingress Information ===${NC}"
    kubectl get ingress -n $NAMESPACE -o wide
    
    echo -e "${GREEN}=== Ingress Description ===${NC}"
    kubectl describe ingress -n $NAMESPACE
}

# Show horizontal pod autoscaler status
show_hpa() {
    echo -e "${GREEN}=== Horizontal Pod Autoscaler ===${NC}"
    kubectl get hpa -n $NAMESPACE
    
    echo -e "${GREEN}=== HPA Description ===${NC}"
    kubectl describe hpa -n $NAMESPACE
}

# Show persistent volume claims
show_pvc() {
    echo -e "${GREEN}=== Persistent Volume Claims ===${NC}"
    kubectl get pvc -n $NAMESPACE
    
    echo -e "${GREEN}=== PVC Descriptions ===${NC}"
    kubectl describe pvc -n $NAMESPACE
}

# Show logs for specific application
show_app_logs() {
    echo -e "${GREEN}=== Application Logs ===${NC}"
    echo -e "${YELLOW}Go App Logs:${NC}"
    kubectl logs -n $NAMESPACE -l app=go-app --tail=50
    
    echo -e "${YELLOW}Redis Logs:${NC}"
    kubectl logs -n $NAMESPACE -l app=redis --tail=20
    
    echo -e "${YELLOW}Postgres Logs:${NC}"
    kubectl logs -n $NAMESPACE -l app=postgres --tail=20
}

# Show events in the namespace
show_events() {
    echo -e "${GREEN}=== Recent Events ===${NC}"
    kubectl get events -n $NAMESPACE --sort-by=.metadata.creationTimestamp
}

# Test application endpoints
test_endpoints() {
    echo -e "${GREEN}=== Testing Application Endpoints ===${NC}"
    
    # Get service endpoint
    SERVICE_IP=$(kubectl get svc go-app-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    
    if [ -z "$SERVICE_IP" ]; then
        echo -e "${YELLOW}LoadBalancer IP not available, trying port-forward...${NC}"
        kubectl port-forward svc/go-app-service 8080:80 -n $NAMESPACE &
        PF_PID=$!
        sleep 5
        
        echo "Testing /ping endpoint:"
        curl -s http://localhost:8080/ping || echo "Failed to reach /ping"
        
        echo "Testing /messages endpoint:"
        curl -s http://localhost:8080/messages || echo "Failed to reach /messages"
        
        kill $PF_PID 2>/dev/null || true
    else
        echo "Service available at: http://$SERVICE_IP"
        echo "Testing /ping endpoint:"
        curl -s http://$SERVICE_IP/ping || echo "Failed to reach /ping"
        
        echo "Testing /messages endpoint:"
        curl -s http://$SERVICE_IP/messages || echo "Failed to reach /messages"
    fi
}

# Show resource usage
show_resource_usage() {
    echo -e "${GREEN}=== Resource Usage ===${NC}"
    
    echo -e "${YELLOW}Pod Resource Usage:${NC}"
    kubectl top pods -n $NAMESPACE 2>/dev/null || echo "Metrics server not available"
    
    echo -e "${YELLOW}Node Resource Usage:${NC}"
    kubectl top nodes 2>/dev/null || echo "Metrics server not available"
}

# Troubleshooting tips
show_troubleshooting_tips() {
    echo -e "${GREEN}=== Troubleshooting Tips ===${NC}"
    echo "1. Check pod logs: kubectl logs -n $NAMESPACE <pod-name>"
    echo "2. Describe pod: kubectl describe pod -n $NAMESPACE <pod-name>"
    echo "3. Check service endpoints: kubectl get endpoints -n $NAMESPACE"
    echo "4. Check ingress: kubectl describe ingress -n $NAMESPACE"
    echo "5. Check configmap: kubectl get configmap -n $NAMESPACE -o yaml"
    echo "6. Check secrets: kubectl get secret -n $NAMESPACE"
    echo "7. Port forward to service: kubectl port-forward svc/go-app-service 8080:80 -n $NAMESPACE"
    echo "8. Connect to pod: kubectl exec -it -n $NAMESPACE <pod-name> -- /bin/sh"
}

# Main menu
show_menu() {
    echo -e "${GREEN}=== EKS Monitoring Menu ===${NC}"
    echo "1. Show cluster info"
    echo "2. Show all resources"
    echo "3. Show pod status"
    echo "4. Show services"
    echo "5. Show ingress"
    echo "6. Show HPA"
    echo "7. Show PVC"
    echo "8. Show application logs"
    echo "9. Show events"
    echo "10. Test endpoints"
    echo "11. Show resource usage"
    echo "12. Show troubleshooting tips"
    echo "13. Full monitoring report"
    echo "0. Exit"
    echo ""
    read -p "Select an option: " choice
}

# Full monitoring report
full_report() {
    echo -e "${GREEN}=== Full Monitoring Report ===${NC}"
    show_cluster_info
    echo ""
    show_all_resources
    echo ""
    show_pod_status
    echo ""
    show_services
    echo ""
    show_ingress
    echo ""
    show_hpa
    echo ""
    show_events
    echo ""
    show_resource_usage
    echo ""
    test_endpoints
}

# Main execution
main() {
    # Check if kubectl is configured
    if ! kubectl cluster-info >/dev/null 2>&1; then
        echo -e "${RED}kubectl is not configured for any cluster. Please run 'aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME'${NC}"
        exit 1
    fi
    
    while true; do
        show_menu
        case $choice in
            1) show_cluster_info ;;
            2) show_all_resources ;;
            3) show_pod_status ;;
            4) show_services ;;
            5) show_ingress ;;
            6) show_hpa ;;
            7) show_pvc ;;
            8) show_app_logs ;;
            9) show_events ;;
            10) test_endpoints ;;
            11) show_resource_usage ;;
            12) show_troubleshooting_tips ;;
            13) full_report ;;
            0) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
        esac
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
}

# Run the main function
main
