# Lab 9 - Services

<span class="lab-badge">25 min</span> <span class="lab-badge">Beginner</span>

## Problem

We have a `jedi-deployment` and a `yoda-deployment` that need to communicate. The Jedi need to be reachable from outside the cluster, while Yoda only needs to talk to the Jedi Council (other workloads inside the cluster).

Look at the two Deployments, then create two Services that meet these requirements:

**`jedi-svc`**

- The Service is named `jedi-svc`.
- It exposes the pods managed by `jedi-deployment`.
- It listens on port `80`, and its `targetPort` matches the port the pods expose.
- Its type is `NodePort`.

**`yoda-svc`**

- The Service is named `yoda-svc`.
- It exposes the pods managed by `yoda-deployment`.
- It listens on port `80`, and its `targetPort` matches the port the pods expose.
- Its type is `ClusterIP`.

## Setup

```bash
oc new-project lab9
```

```bash
oc apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jedi-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: jedi
  template:
    metadata:
      labels:
        app: jedi
    spec:
      containers:
        - name: jedi
          image: quay.io/nginx/nginx-unprivileged:1.29
          ports:
            - containerPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: yoda-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: yoda
  template:
    metadata:
      labels:
        app: yoda
    spec:
      containers:
        - name: yoda
          image: quay.io/nginx/nginx-unprivileged:1.29
          ports:
            - containerPort: 8080
EOF
```

## Verification

1. Each Service has two endpoints on port `8080`:

    ```bash
    oc get services
    oc get endpointslices
    ```

2. The Jedi can reach Yoda inside the cluster by the Service's DNS name:

    ```bash
    oc exec deploy/jedi-deployment -- curl -s -o /dev/null -w '%{http_code}\n' http://yoda-svc
    ```

    This prints `200`.

3. `jedi-svc` answers on its node port, on every node's IP address:

    ```bash
    NODE_PORT=$(oc get service jedi-svc -o jsonpath='{.spec.ports[0].nodePort}')
    NODE_IP=$(oc get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
    oc exec deploy/yoda-deployment -- curl -s -o /dev/null -w '%{http_code}\n' "http://${NODE_IP}:${NODE_PORT}"
    ```

    This also prints `200`.

!!! note "NodePorts on OpenShift"
    On most OpenShift clusters, nodes sit on a private network, and you may not have permission to list nodes. Apps are normally published outside the cluster with a **Route** instead of a NodePort. You'll do that in [Lab 11](../lab11/index.md).

## Cleanup

```bash
oc delete project lab9
```
