Section 2 – Task A: Troubleshooting – 502 Bad Gateway (Nginx + Node.js)
----------------------------------------------------------------------

Scenario
--------
An application is running in Docker using NGINX as a reverse proxy for a Node.js backend.
When accessing the application via NGINX, users encounter a 502 Bad Gateway error.
This indicates that NGINX was unable to connect to the upstream app server.

Root Cause
----------
After investigating the configuration i found the issue in `nginx.conf`, where:

    proxy_pass http://web:8080;

It was pointing to port 8080 while the Node.js app was actually listening on port 3000.
This mismatch led to a connection failure between NGINX and the backend container.

Fix Applied
-----------
Updated `nginx.conf` to use the correct port:

    proxy_pass http://web:3000;

Then restarted the environment:

    docker compose down
    docker compose up --build

After the fix, accessing http://localhost should return the expected response from the backend.

Prevention Strategies
---------------------

1. Add Healthchecks (Docker)
----------------------------
Using Docker Compose healthchecks ensures the app is up before NGINX starts proxying:

    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3

2. Use Liveness & Readiness Probes (Kubernetes)
-----------------------------------------------
    livenessProbe:
      httpGet:
        path: /health
        port: 3000

    readinessProbe:
      httpGet:
        path: /health
        port: 3000

And in the Node.js app:

    app.get('/health', (req, res) => res.sendStatus(200));

3. Monitoring & Automation
--------------------------
To catch and resolve issues earlier in production we could use:
- Monitoring tools like Prometheus + Grafana
- Automate log inspection with scheduled jobs or alerting tools
- Consider startup delays and health-based orchestration

Summary
-------
This issue was caused by a simple port mismatch between NGINX and the backend.
Careful validation of proxy configuration and container health can prevent these issues.
We should also ensure proxies, services, and apps agree on port numbers and readiness states.
