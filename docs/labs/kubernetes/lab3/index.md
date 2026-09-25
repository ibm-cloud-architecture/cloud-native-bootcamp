---
tags:
  - Lab
  - Troubleshooting
  - Intermediate
---

# Lab 3 - Debugging

<span class="lab-badge">30 min</span> <span class="lab-badge">Intermediate</span>

## Problem

The Hyper Drive isn't working, and we need to find out why. Debug the `hyper-drive` deployment and its service so we can reach light speed again.

Some tips to get you started:

- Check the status and description of the `deployment` and its `pods`.
- Get the logs of one of the broken pods and save them to a file.
- Check that the correct `ports` are used everywhere.
- Make sure your `labels` and `selectors` match.
- Check that the `probes` are working.

The application listens on port `8080` and serves its health check on `/healthz`.

## Setup

Create a project, then apply the broken application:

```bash
oc new-project vader
```

```bash
oc apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hyper-drive
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hyper-drive
  template:
    metadata:
      labels:
        app: hyper-drive
    spec:
      containers:
        - name: hyper-drive
          image: registry.k8s.io/e2e-test-images/agnhost:2.56
          args: ["netexec", "--http-port=8080"]
          ports:
            - containerPort: 8080
          livenessProbe:
            tcpSocket:
              port: 80
---
apiVersion: v1
kind: Service
metadata:
  name: hyper-drive
spec:
  selector:
    run: hyper-drive
  ports:
    - protocol: TCP
      port: 80
EOF
```

Wait a minute or two before you start. Some of the problems only show up after the pods have been running for a while.

## Verification

You're done when all of the following are true:

1. All 3 `hyper-drive` pods are `Running`, `1/1` ready, and their `RESTARTS` count has stopped increasing:

    ```bash
    oc get pods -l app=hyper-drive
    ```

2. The service has 3 endpoints on port `8080`:

    ```bash
    oc get endpointslices -l kubernetes.io/service-name=hyper-drive
    ```

3. The service answers from inside the cluster. Start a client pod, then call the service by name:

    ```bash
    oc run client --image=registry.access.redhat.com/ubi9/ubi-minimal -- sleep infinity
    oc wait --for=condition=Ready pod/client
    oc exec client -- curl -s --max-time 5 hyper-drive/hostname
    ```

    This prints the name of one of the `hyper-drive` pods.

## Cleanup

```bash
oc delete project vader
```
