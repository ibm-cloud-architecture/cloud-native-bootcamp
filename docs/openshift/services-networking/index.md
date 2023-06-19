# Services

An abstract way to expose an application running on a set of Pods as a network service.

Kubernetes Pods are mortal. They are born and when they die, they are not resurrected. If you use a Deployment to run your app, it can create and destroy Pods dynamically.

Each Pod gets its own IP address, however in a Deployment, the set of Pods running in one moment in time could be different from the set of Pods running that application a moment later.

In Kubernetes, a Service is an abstraction which defines a logical set of Pods and a policy by which to access them (sometimes this pattern is called a micro-service). The set of Pods targeted by a Service is usually determined by a selector (see below for why you might want a Service without a selector).

If you’re able to use Kubernetes APIs for service discovery in your application, you can query the API server for Endpoints, that get updated whenever the set of Pods in a Service changes.

For non-native applications, Kubernetes offers ways to place a network port or load balancer in between your application and the backend Pods.


## Resources

=== "OpenShift & Kubernetes"

    [Services :fontawesome-solid-globe:](https://kubernetes.io/docs/concepts/services-networking/service/){ .md-button target="_blank"}

    [Exposing Services :fontawesome-solid-globe:](https://kubernetes.io/docs/tutorials/kubernetes-basics/expose/expose-intro/){ .md-button target="_blank"}

## References

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
  labels:
    app: nginx
    version: v1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
        version: v1
    spec:
      containers:
      - name: nginx
        image: bitnami/nginx
        ports:
        - containerPort: 8080
          name: http
---
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: nginx
  ports:
    - name: http
      port: 80
      targetPort: http
```
=== "OpenShift"

    ```Bash title="Get Logs"
    oc logs
    ```

    ``` Bash title="Use Stern to View Logs"
    brew install stern
    stern . -n default
    ```

=== "Kubernetes"

    ``` Bash title="Get Logs"
    kubectl logs
    ```

    ``` Bash title="Use Stern to View Logs"
    brew install stern
    stern . -n default
    ```

```
```

=== "OpenShift"

    ``` Bash title="Get Service"
    oc get svc
    ```

    ``` Bash title="Get Service Description"
    oc describe svc my-service
    ```

    ``` Bash title="Expose a Service"
    oc expose service <service_name>
    ```

    ``` Bash title="Get Route for the Service"
    oc get route
    ```

=== "Kubernetes"

    ``` Bash title="Get Service"
    kubectl get svc
    ```

    ``` Bash title="Get Service Description"
    kubectl describe svc my-service
    ```

    ``` Bash title="Get Service Endpoints"
    kubectl get ep my-service
    ```

    ``` Bash title="Expose a Deployment via a Service"
    kubectl expose deployment my-deployment --port 80 --target-port=http --selector app=nginx --name my-service-2 --type NodePort
    ```

## Activities

| Task                            | Description         | Link        |
| --------------------------------| ------------------  |:----------- |
| *** Try It Yourself ***                         |         |         | 
| Creating Services | Create two services with certain requirements. | [Setting up Services](../../labs/kubernetes/lab8/index.md) |
| IKS Ingress Controller | Configure Ingress on Free IKS Cluster | [Setting IKS Ingress](../../labs/kubernetes/ingress-iks/index.md) |
