---
tags:
  - Lab
  - Workloads
  - Beginner
---

# Lab 7 - Rolling Updates

<span class="lab-badge">25 min</span> <span class="lab-badge">Beginner</span>

## Problem

Your company's developers have just finished a new version of their Jedi-themed mobile game, and they're ready to update the backend running in your cluster. A Deployment named `jedi-deployment` manages the application replicas.

Update the container named `jedi-ws` to the new image `quay.io/nginx/nginx-unprivileged:1.29` using a rolling update, and confirm the rollout succeeds. Then a teammate pushes a broken release. Roll it back.

## Setup

```bash
oc new-project lab7
```

Save this manifest to `jedi-deployment.yaml` and apply it:

```yaml title="jedi-deployment.yaml"
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
          image: quay.io/nginx/nginx-unprivileged:1.28
          ports:
            - containerPort: 8080
```

```bash
oc apply -f jedi-deployment.yaml
oc rollout status deployment/jedi-deployment
```

## Tasks

1. **Update** the `jedi-ws` container to `quay.io/nginx/nginx-unprivileged:1.29`, and record why you changed it in the `kubernetes.io/change-cause` annotation.
2. **Watch** the rollout until it completes.
3. **View** the rollout history. You should see two revisions.
4. **Deploy a broken release**: update the image to `quay.io/nginx/nginx-unprivileged:9.99`, a tag that doesn't exist. Check the rollout status and the pods. What happens to the old pods?
5. **Roll back** to the working version.

## Hints

- `oc set image` changes a container's image.
- `oc annotate` sets the change cause. The old `--record` flag is deprecated.
- `oc rollout status`, `oc rollout history` and `oc rollout undo` manage rollouts.
- Watch the pods change in real time with `oc get pods -l app=jedi -w`.

## Verification

After the rollback, the Deployment runs version 1.29 with all 3 replicas available:

```bash
oc get deployment jedi-deployment -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
oc get deployment jedi-deployment
oc rollout history deployment/jedi-deployment
```

## Cleanup

```bash
oc delete project lab7
```
