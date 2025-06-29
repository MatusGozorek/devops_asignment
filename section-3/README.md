Section 3 – Task A: Thought Process – "App is Down in Production"
-----------------------------------------------------------------

Scenario
--------
An application is running in a Kubernetes cluster and is suddenly reported as "down in production". Below is my step-by-step investigation process to identify and resolve the issue.



Step-by-Step Investigation Strategy
-----------------------------------

1. Check if Kubernetes Is Healthy
---------------------------------
Before checking the app itself I would confirm that the cluster is running properly:

kubectl cluster-info
kubectl get nodes

If the nodes are NotReady I would investigate the underlying infrastructure.

2. Check the Core Kubernetes Services
-------------------------------------
Next I would check the control plane and system-level components:

kubectl get all -n kube-system

This helps identify problems like:
- Crashing DNS pods
- Missing controller-manager or scheduler
- Problems with CNI plugins

3. Check the Application Itself
-------------------------------
Next I would target the actual application namespace:

kubectl get all -n <your-namespace>

Look for:
- Pods stuck in Pending or CrashLoopBackOff
- Deployment replicas not matching desired count
- Missing or misconfigured Services or Ingress

4. Inspect Specific Pods
------------------------
For any suspicious pods I would use:

kubectl describe pod <pod-name> 

Key things to check:
- Container image errors
- Port or liveness/readiness probe failures
- VolumeMount errors
- Events at the bottom  (Warnings and Errors)

5. Validate Configuration
-------------------------
I would then review configuration settings:
- Check if pod labels match the Service selector
- Confirm Ingress routes point to the right Service
- Ensure the correct namespace and object names are used in Deployments, Services, and Ingress

6. Check Resource Quotas / Limits
---------------------------------
If pods are Pending:

kubectl describe pod <pod> | grep -i memory

I might find something like:
- Memory limits too low
- Node resources exhausted

7. Check Ingress / External Access
----------------------------------
If pods are running but users cant access the app:
- Check Ingress:
  kubectl get ingress -A
- Validate DNS and external IPs
- Run curl from inside the cluster:
  kubectl exec -it <pod> -- curl http://<service-name>:<port>

8. Correct the Issue
--------------------
If a misconfiguration is found, I would:
- Update the YAML files
- Redeploy using kubectl apply -f or Helm
- Monitor with kubectl get pods until healthy

9. If the Issue Persists
------------------------
If the root cause is not clear:
- Check logs: kubectl logs <pod>
- Search known issues on GitHub, Stack Overflow, or vendor docs
- If working in team I would involve teammates 

Summary
-------
My troubleshooting philosophy is isolation, targeted inspection, and logical elimination.
I start from cluster health and narrow down to the application — identifying misconfigurations, failed probes, and networking issues.
Also root cause of alot problems are in naming.
