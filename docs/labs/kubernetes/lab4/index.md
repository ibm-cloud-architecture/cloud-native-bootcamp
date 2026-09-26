---
tags:
  - Lab
  - Pods
  - Intermediate
---

# Lab 4 - Multi-Container Pods

<span class="lab-badge">30 min</span> <span class="lab-badge">Intermediate</span>

## Problem

The `millennium-falcon` service has already been packaged into a container image, but it comes with a special requirement:

- The legacy app is hard-coded to serve only on port `8989`, but the team wants to reach it on the standard web port `8080`.

Your task is to build a Pod that runs the legacy container and uses the **ambassador** pattern to expose it on port `8080`. The ambassador is a second container in the same Pod that proxies traffic to the legacy app. Containers in a Pod share a network namespace, so the ambassador can reach the app on `127.0.0.1`.

The Pod must meet these requirements:

- The Pod is named `vader-service`.
- It has a container named `millennium-falcon` that runs the legacy image `registry.k8s.io/e2e-test-images/agnhost:2.56` with the arguments `netexec` and `--http-port=8989`.
- It has an ambassador container named `nginx-ambassador` that runs the `quay.io/nginx/nginx-unprivileged:1.29` image and proxies incoming traffic on port `8080` to the legacy service on port `8989`.
- Port `8080` is exposed as a `containerPort` on the ambassador. You don't need to expose port `8989`.
- The nginx configuration is stored in a ConfigMap named `vader-service-ambassador-config`, under the key `default.conf`, with this content:

    ```nginx
    server {
        listen 8080;
        location / {
            proxy_pass http://127.0.0.1:8989;
        }
    }
    ```

- The ConfigMap is mounted into the ambassador container as a volume at `/etc/nginx/conf.d`, so the file ends up at `/etc/nginx/conf.d/default.conf`.

## Setup

```bash
oc new-project lab4
```

## Verification

Test the service from inside the cluster through port `8080`. Create a client Pod to send requests from:

```yaml title="client.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: client
spec:
  containers:
    - name: client
      image: registry.access.redhat.com/ubi9/ubi-minimal
      command: ["sleep", "infinity"]
```

```bash
oc apply -f client.yaml
oc wait --for=condition=Ready pod/client pod/vader-service
```

Call `vader-service` on port `8080` from the client Pod:

```bash
oc exec client -- curl -s "$(oc get pod vader-service -o jsonpath='{.status.podIP}'):8080/echo?msg=The+hyperdrive+needs+repair"
```

If the ambassador is working, the legacy app echoes back `The hyperdrive needs repair`.

## Cleanup

```bash
oc delete project lab4
```

_Relevant documentation:_

- [Pods with multiple containers](https://kubernetes.io/docs/concepts/workloads/pods/#how-pods-manage-multiple-containers)
- [Sidecar containers](https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/)
- [Configure a Pod to use a ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
