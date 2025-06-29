#!/bin/bash

# Uninstall the application Helm release if it exists
echo "Uninstalling nginx-app..."
helm uninstall nginx-app --namespace default 2>/dev/null || true

# Uninstall the ingress controller Helm release if it exists
echo "Uninstalling nginx-ingress..."
helm uninstall nginx-ingress --namespace default 2>/dev/null || true
