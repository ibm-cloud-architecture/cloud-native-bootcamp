---
tags:
  - Solution
  - Troubleshooting
---

# Lab 3 Solution - Debugging

There are three problems:

| Problem | Symptom | Fix |
| --- | --- | --- |
| The liveness probe checks TCP port `80`, but the app listens on `8080` | Pods restart every ~30 seconds and eventually go into `CrashLoopBackOff` | Probe `/healthz` on port `8080` |
| The service selector is `run: hyper-drive`, but the pods are labelled `app: hyper-drive` | The service has no endpoints | Change the selector to `app: hyper-drive` |
| The service has no `targetPort`, so it defaults to `port` (`80`) | Endpoints exist but connections are refused | Set `targetPort: 8080` |

## Investigate

```bash
# Pods are running but restarting
oc get pods -l app=hyper-drive

# Events show the failing probe
oc describe deployment hyper-drive
oc describe pod <pod-name> | grep -A 10 Events
# Liveness probe failed: dial tcp 10.x.x.x:80: connect: connection refused

# Save the logs of a broken pod (use --previous for the container that was killed)
oc logs <pod-name> --previous > broken-pod-logs.log

# Compare the service selector with the pod labels
oc describe service hyper-drive
oc get pods --show-labels

# No endpoints are listed for the service
oc get endpointslices -l kubernetes.io/service-name=hyper-drive
```

## Fix the deployment

You can edit the live object directly. Probes can be changed with `oc edit`, and the deployment then rolls out new pods:

```bash
oc edit deployment hyper-drive
```

On OpenShift, `oc set probe` does the same thing without an editor:

```bash
oc set probe deployment/hyper-drive --liveness --remove
oc set probe deployment/hyper-drive --liveness --get-url=http://:8080/healthz
```

Either way, the container should end up with:

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
```

!!! tip "Prefer declarative fixes"
    In real projects, export the manifest (`oc get deployment hyper-drive -o yaml > hyper-drive.yaml`), remove runtime fields such as `status`, `metadata.uid` and `metadata.resourceVersion`, fix it, and `oc apply -f` it. Better still, fix the manifest in Git and let your pipeline or GitOps tool apply it.

## Fix the service

```bash
oc patch service hyper-drive --type=merge \
  -p '{"spec":{"selector":{"run":null,"app":"hyper-drive"},"ports":[{"protocol":"TCP","port":80,"targetPort":8080}]}}'
```

Or apply the corrected manifest:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: hyper-drive
spec:
  selector:
    app: hyper-drive
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

## Verify

```bash
oc rollout status deployment/hyper-drive
oc get endpointslices -l kubernetes.io/service-name=hyper-drive
oc run client --image=registry.access.redhat.com/ubi9/ubi-minimal -- sleep infinity
oc wait --for=condition=Ready pod/client
oc exec client -- curl -s --max-time 5 hyper-drive/hostname
```

The last command prints the name of one of the `hyper-drive` pods. Run it a few times: the Service load-balances across all three pods.
