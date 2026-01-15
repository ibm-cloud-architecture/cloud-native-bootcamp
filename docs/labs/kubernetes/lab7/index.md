# Kubernetes Lab 7 - Rolling Updates

## Problem

Your company's developers have just finished developing a new version of their jedi-themed mobile game. They are ready to update the backend services that are running in your Kubernetes cluster. There is a deployment in the cluster managing the replicas for this application. The deployment is called `jedi-deployment`. You have been asked to update the image for the container named `jedi-ws` in this deployment template to a new version, `bitnami/nginx:1.19.0`.

After you have updated the image using a rolling update, check on the status of the update to make sure it is working. If it is not working, perform a rollback to the previous state.

## Setup

First, create the initial deployment by saving the following YAML to a file named `jedi-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jedi-deployment
  labels:
    app: jedi
spec:
  replicas: 3
  selector:
    matchLabels:
      app: jedi
  template:
    metadata:
      labels:
        app: jedi
    spec:
      containers:
      - name: jedi-ws
        image: bitnami/nginx:1.18.0
        ports:
        - containerPort: 8080
```

Apply the deployment:

```bash
kubectl apply -f jedi-deployment.yaml
```

Verify the deployment is running:

```bash
kubectl get deployment jedi-deployment
kubectl get pods -l app=jedi
```

## Tasks

1. **Update the deployment** to use the new image `bitnami/nginx:1.19.0` for the container named `jedi-ws`
2. **Check the rollout status** to verify the update is progressing
3. **View the rollout history** to see the deployment revisions
4. If the update fails, **perform a rollback** to the previous working version

## Hints

- Use `kubectl set image` to update the container image
- Use `kubectl rollout status` to check rollout progress
- Use `kubectl rollout history` to view revision history
- Use `kubectl rollout undo` to rollback if needed
- Watch pods in real-time with `kubectl get pods -w`

## Verification

After completing the lab, you should be able to:

1. See the deployment running with the updated image:

   ```bash
   kubectl describe deployment jedi-deployment | grep Image
   ```

2. View the rollout history showing multiple revisions:

   ```bash
   kubectl rollout history deployment/jedi-deployment
   ```

## Cleanup

```bash
kubectl delete deployment jedi-deployment
```
