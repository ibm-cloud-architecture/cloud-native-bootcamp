# Lab 9 Solution - Services

The pods expose port `8080` and carry the labels `app: jedi` and `app: yoda`. Check with `oc describe deployment jedi-deployment` or `oc get pods --show-labels`.

```yaml title="services.yaml"
apiVersion: v1
kind: Service
metadata:
  name: jedi-svc
spec:
  type: NodePort
  selector:
    app: jedi
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: yoda-svc
spec:
  type: ClusterIP
  selector:
    app: yoda
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

```bash
oc apply -f services.yaml
oc get services
```

```text title="Expected output"
NAME       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
jedi-svc   NodePort    172.30.47.112   <none>        80:31234/TCP   5s
yoda-svc   ClusterIP   172.30.180.23   <none>        80/TCP         5s
```

!!! tip "Imperative alternative"
    `oc expose` creates the same Services straight from the Deployments. It copies the selector from the Deployment for you:

    ```bash
    oc expose deployment jedi-deployment --name=jedi-svc --type=NodePort --port=80 --target-port=8080
    oc expose deployment yoda-deployment --name=yoda-svc --port=80 --target-port=8080
    ```
