Section 1 – Task C: Deploy Kubernetes App with Helm
------------------------------------------------------

Scenario
--------
A simple NGINX web application needs to be deployed in a Kubernetes cluster using Helm. The task involves customizing "values.yaml", configuring Ingress and Service resources, and exposing the app externally via a domain (`nginx.local`).

Setup Overview
--------------
- Deployment: Runs a single `nginx:stable` pod.
- Service: Exposes NGINX on port 80 using `ClusterIP`.
- Ingress: Routes traffic from `nginx.local` to the NGINX service.
- Platform: Local `k3s` cluster with `MetalLB` and `NGINX Ingress Controller`.

Helm Chart Values Used
-----------------------
name: nginx-app
replicaCount: 1

image:
  repository: nginx
  tag: stable
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

livenessProbe:
  httpGet:
    path: /
    port: http

readinessProbe:
  httpGet:
    path: /
    port: http

ingress:
  enabled: true
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  host: nginx.local
  path: /
  pathType: Prefix

How to Deploy
-------------
# 0. Install MetalLB if not already installed
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml

# Define an IP pool for MetalLB (adjust range to match your LAN)
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.185-192.168.1.190
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2
  namespace: metallb-system
EOF

# 1. Install NGINX Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx --set controller.service.type=LoadBalancer

# 2. Wait until ingress controller is ready
kubectl rollout status deployment nginx-ingress-ingress-nginx-controller

# 3. Deploy the Helm chart
helm install nginx-app ./nginx-app

# 4. Add to /etc/hosts (example IP from MetalLB range)
192.168.1.185  nginx.local

# 5. Test it
curl http://nginx.local

Expected Output
---------------
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and working.</p>

Cleanup
-------
helm uninstall nginx-app
helm uninstall nginx-ingress

Summary
-------
This section demonstrates a basic yet production-style deployment using Helm in Kubernetes. The chart was simplified to expose only the values actually used in templates. Ingress routing is handled with MetalLB and NGINX Ingress Controller, providing external access even on a local k3s cluster.
