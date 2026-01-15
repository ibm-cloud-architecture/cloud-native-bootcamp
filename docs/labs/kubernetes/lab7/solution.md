# Kubernetes Lab 7 - Rolling Updates

## Solution

### Step 1: Update the deployment to the new version

```bash
kubectl set image deployment/jedi-deployment jedi-ws=bitnami/nginx:1.19.0
```

### Step 2: Check the progress of the rolling update

```bash
kubectl rollout status deployment/jedi-deployment
```

In another terminal window, watch the pods:

```bash
kubectl get pods -w
```

### Step 3: View the rollout history

Get a list of previous revisions:

```bash
kubectl rollout history deployment/jedi-deployment
```

### Step 4: Rollback if needed

If the update fails or you need to rollback, undo the last revision:

```bash
kubectl rollout undo deployment/jedi-deployment
```

Check the status of the rollback:

```bash
kubectl rollout status deployment/jedi-deployment
```

### Verify the current image

```bash
kubectl describe deployment jedi-deployment | grep Image
```

Expected output after successful update:

```
Image: bitnami/nginx:1.19.0
```
