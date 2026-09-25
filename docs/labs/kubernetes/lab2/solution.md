# Lab 2 Solution - Probes

```yaml title="energy-shield-service.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: energy-shield-service
spec:
  containers:
    - name: energy-shield
      image: registry.k8s.io/e2e-test-images/agnhost:2.56
      args: ["liveness"]
      ports:
        - containerPort: 8080
      livenessProbe:
        httpGet:
          path: /healthz
          port: 8080
        initialDelaySeconds: 5
        periodSeconds: 5
      readinessProbe:
        httpGet:
          path: /healthz
          port: 8080
        initialDelaySeconds: 5
        periodSeconds: 5
```

```bash
oc apply -f energy-shield-service.yaml
oc get pod energy-shield-service -w
```

```text title="Expected output (abridged)"
NAME                    READY   STATUS    RESTARTS      AGE
energy-shield-service   0/1     Running   0             5s
energy-shield-service   1/1     Running   0             9s
energy-shield-service   0/1     Running   0             25s
energy-shield-service   0/1     Running   1 (3s ago)    29s
energy-shield-service   1/1     Running   1 (7s ago)    33s
```

## How it works

- **Liveness probe**: the kubelet calls `/healthz` every 5 seconds (`periodSeconds`). After 3 consecutive failures (the default `failureThreshold`), it kills the container and restarts it.
- **Readiness probe**: while it's failing, the Pod is removed from Service endpoints, so it gets no traffic. It doesn't restart the container.
- **Startup probe** (not needed here): for slow-starting apps, a `startupProbe` holds off the liveness and readiness probes until the app has started, so you don't need a long `initialDelaySeconds`.
