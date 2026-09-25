# Lab 4 Solution - Multi-Container Pods

```yaml title="vader-service.yaml"
apiVersion: v1
kind: ConfigMap
metadata:
  name: vader-service-ambassador-config
data:
  default.conf: |
    server {
        listen 8080;
        location / {
            proxy_pass http://127.0.0.1:8989;
        }
    }
---
apiVersion: v1
kind: Pod
metadata:
  name: vader-service
spec:
  containers:
    - name: millennium-falcon
      image: registry.k8s.io/e2e-test-images/agnhost:2.56
      args: ["netexec", "--http-port=8989"]
    - name: nginx-ambassador
      image: quay.io/nginx/nginx-unprivileged:1.29
      ports:
        - containerPort: 8080
      volumeMounts:
        - name: config-volume
          mountPath: /etc/nginx/conf.d
  volumes:
    - name: config-volume
      configMap:
        name: vader-service-ambassador-config
```

```bash
oc apply -f vader-service.yaml
oc get pod vader-service
```

```text title="Expected output"
NAME            READY   STATUS    RESTARTS   AGE
vader-service   2/2     Running   0          15s
```

`2/2` means both containers are running. Test it from the client Pod:

```bash
oc exec client -- curl -s "$(oc get pod vader-service -o jsonpath='{.status.podIP}'):8080/echo?msg=The+hyperdrive+needs+repair"
```

```text title="Expected output"
The hyperdrive needs repair
```

!!! tip "Sidecar containers"
    Since Kubernetes 1.29 (OpenShift 4.16), you can also declare helper containers as **native sidecars**: put them under `initContainers` with `restartPolicy: Always`. Native sidecars start before the app containers and stop after them, which matters for proxies and log shippers. A plain second container, as used here, is fine for a long-running Pod like this one.
