# Lab 6 Solution - Pod Configuration

Create the ConfigMap, Secret and ServiceAccount. You can do this imperatively:

```bash
oc create configmap yoda-service-config \
  --from-literal=yoda.cfg=$'yoda.baby.power=100000000\nyoda.strength=10'
oc create secret generic yoda-db-password --from-literal=password='0penSh1ftRul3s!'
oc create serviceaccount yoda-svc
```

Or declaratively:

```yaml title="yoda-service-config.yaml"
apiVersion: v1
kind: ConfigMap
metadata:
  name: yoda-service-config
data:
  yoda.cfg: |
    yoda.baby.power=100000000
    yoda.strength=10
---
apiVersion: v1
kind: Secret
metadata:
  name: yoda-db-password
type: Opaque
stringData:
  password: 0penSh1ftRul3s!
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: yoda-svc
```

Then create the Pod:

```yaml title="yoda-service-pod.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: yoda-service
spec:
  serviceAccountName: yoda-svc
  containers:
    - name: yoda-service
      image: quay.io/nginx/nginx-unprivileged:1.29
      env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: yoda-db-password
              key: password
      resources:
        requests:
          memory: 64Mi
          cpu: 250m
        limits:
          memory: 128Mi
          cpu: 500m
      volumeMounts:
        - name: config-volume
          mountPath: /etc/yoda-service
  volumes:
    - name: config-volume
      configMap:
        name: yoda-service-config
```

```bash
oc apply -f yoda-service-config.yaml
oc apply -f yoda-service-pod.yaml
oc exec yoda-service -- cat /etc/yoda-service/yoda.cfg
```

```text title="Expected output"
yoda.baby.power=100000000
yoda.strength=10
```

!!! warning "Secrets are encoded, not encrypted"
    `stringData` is a convenience: the API server stores the value base64-encoded in `data`. Anyone who can read Secrets in the project can decode it. Restrict access with RBAC, and consider an external secret manager (for example, the External Secrets Operator with HashiCorp Vault or IBM Cloud Secrets Manager) for production credentials.
