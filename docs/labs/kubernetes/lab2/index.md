---
tags:
  - Lab
  - Pods
  - Observability
  - Beginner
---

# Lab 2 - Probes

<span class="lab-badge">20 min</span> <span class="lab-badge">Beginner</span>

## Problem

The `energy-shield` service has two problems in production.

### Container health issues

After running for a short while, the application goes into an unhealthy state and starts answering requests with errors. The process doesn't crash, so the container keeps running and OpenShift never restarts it.

The application has an internal health endpoint that reports whether it's healthy: `/healthz` on port `8080`.

- **Add a liveness probe** that checks `/healthz` on port `8080`. If the endpoint returns an error, the cluster restarts the container.

### Container startup issues

New Pods take a few seconds after startup before they can serve requests, and some users hit errors during that window.

- **Add a readiness probe** that checks `/healthz` on port `8080`, so the Pod only receives traffic when it's ready.
- On **both** probes, set an **initial delay of 5 seconds** and check **every 5 seconds**.

## Setup

```bash
oc new-project lab2
```

Here is the Pod manifest. **Add** the probes, then **create** the Pod in the cluster:

```yaml title="energy-shield-service.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: energy-shield-service
spec:
  containers:
    - name: energy-shield
      image: registry.k8s.io/e2e-test-images/agnhost:2.56
      args: ["liveness"] # (1)!
      ports:
        - containerPort: 8080
```

1. The `liveness` mode of this test image simulates our buggy service. `/healthz` returns `200 OK` for about 10 seconds, then returns `500` forever, while the process keeps running.

## Verification

Watch the Pod for about a minute:

```bash
oc get pod energy-shield-service -w
```

With working probes you should see:

- `READY` shows `0/1` for the first few seconds, then `1/1` once the readiness probe passes.
- About 20 seconds in, the app goes unhealthy. `READY` drops back to `0/1` (readiness probe), and a few seconds later the `RESTARTS` count goes up (liveness probe).
- The cycle repeats. Each restart gives the app a fresh start, and it only gets traffic while it's healthy.

Check the events to see the probes in action:

```bash
oc describe pod energy-shield-service | grep -A 10 Events
```

Look for `Liveness probe failed: HTTP probe failed with statuscode: 500` followed by `Container energy-shield failed liveness probe, will be restarted`.

!!! question "Think about it"
    Without the liveness probe, how long would this Pod keep serving errors? Try it: delete the Pod, recreate it without probes, and watch the `RESTARTS` column.

## Cleanup

```bash
oc delete project lab2
```
