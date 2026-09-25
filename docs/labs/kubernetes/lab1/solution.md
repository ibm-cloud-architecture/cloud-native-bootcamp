---
tags:
  - Solution
  - Pods
---

# Lab 1 Solution - Pod Creation

```yaml title="yoda-service-pod.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: yoda-service
  namespace: web
  labels:
    app: yoda
spec:
  containers:
    - name: nginx
      image: quay.io/nginx/nginx-unprivileged:1.29
      command: ["nginx"]
      args: ["-g", "daemon off;"]
      ports:
        - containerPort: 8080
```

```bash
oc new-project web
oc apply -f yoda-service-pod.yaml
oc get pods -n web
```

```text title="Expected output"
NAME           READY   STATUS    RESTARTS   AGE
yoda-service   1/1     Running   0          20s
```

!!! tip
    `command` overrides the image's `ENTRYPOINT`, and `args` overrides its `CMD`. The `-g "daemon off;"` directive keeps nginx in the foreground. If it forked into the background, the container's main process would exit and the Pod would restart over and over.
