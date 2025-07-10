#!/bin/bash

# Setup Monitoring Stack (Prometheus + Grafana)
# This script sets up monitoring for the EKS cluster

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up monitoring stack...${NC}"

# Create monitoring namespace
echo -e "${YELLOW}Creating monitoring namespace...${NC}"
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Add Prometheus Helm repository
echo -e "${YELLOW}Adding Prometheus Helm repository...${NC}"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus stack
echo -e "${YELLOW}Installing Prometheus stack...${NC}"
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword=admin123 \
  --set grafana.service.type=LoadBalancer \
  --set prometheus.service.type=LoadBalancer

# Apply resource management
echo -e "${YELLOW}Applying resource management...${NC}"
kubectl apply -f k8s/monitoring/resource-management.yaml

echo -e "${GREEN}Monitoring stack installed successfully!${NC}"
echo ""
echo -e "${YELLOW}Getting service URLs...${NC}"
echo "Grafana: http://$(kubectl get svc -n monitoring prometheus-grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "Prometheus: http://$(kubectl get svc -n monitoring prometheus-kube-prometheus-prometheus -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):9090"
echo ""
echo -e "${YELLOW}Grafana credentials:${NC}"
echo "Username: admin"
echo "Password: admin123"
echo ""
echo -e "${YELLOW}Useful monitoring commands:${NC}"
echo "Check monitoring pods: kubectl get pods -n monitoring"
echo "Port forward Grafana: kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "Port forward Prometheus: kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
