#!/bin/bash

# Add the repo and update it
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install ingress controller and wait for it to be ready
echo "Installing NGINX Ingress Controller..."
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --set controller.service.type=LoadBalancer

echo "Waiting for Ingress Controller to be ready..."
kubectl rollout status deployment nginx-ingress-ingress-nginx-controller --timeout=90s

# Install the app
echo "Installing nginx-app..."
helm install nginx-app ./nginx-app

echo "Done. You can now test the app at http://nginx.local after updating /etc/hosts."
