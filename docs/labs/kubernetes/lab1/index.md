---
tags:
  - Lab
  - Pods
  - Beginner
---

# Lab 1 - Pod Creation

<span class="lab-badge">15 min</span> <span class="lab-badge">Beginner</span>

## Problem

Write a Pod manifest in a file named `yoda-service-pod.yaml`, then create the Pod in the cluster to prove it works.

The Pod must meet these requirements:

- The Pod is named `yoda-service` and has the label `app: yoda`.
- It runs in a project (namespace) named `web`.
- It uses the `quay.io/nginx/nginx-unprivileged:1.29` container image.
- The container exposes `containerPort` `8080`.
- The container's command is `nginx`, with the arguments `-g` and `daemon off;`, so nginx runs in the foreground.

!!! info "Why port 8080 and not 80?"
    OpenShift runs containers as a random, non-root user, and non-root processes can't bind to ports below 1024. OpenShift-friendly images, such as `nginx-unprivileged` or Red Hat's UBI images, listen on a high port such as 8080 instead.

## Setup

```bash
oc new-project web
```

## Verification

The Pod should reach the `Running` state with `1/1` containers ready:

```bash
oc get pods -n web
oc describe pod yoda-service -n web
```

Forward a local port to the Pod and request the nginx welcome page. Run `oc port-forward` in one terminal and `curl` in another:

```bash
oc port-forward pod/yoda-service 8080:8080 -n web
```

```bash
curl -s localhost:8080 | grep "<title>"
```

## Cleanup

```bash
oc delete project web
```
