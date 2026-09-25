# Ingress

An API object that manages external access to the services in a cluster, typically HTTP.

Ingress can provide load balancing, SSL termination and name-based virtual hosting.

Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.

## Resources

=== "OpenShift"

    [Ingress Operator :fontawesome-solid-door-open:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/ingress_and_load_balancing/index){ .md-button target="_blank"}

    [Using Ingress Controllers :fontawesome-solid-door-open:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/ingress_and_load_balancing/configuring-ingress-cluster-traffic){ .md-button target="_blank"}

=== "Kubernetes"

    [Ingress :fontawesome-solid-door-open:](https://kubernetes.io/docs/concepts/services-networking/ingress/){ .md-button target="_blank"}

    [Ingress Controllers :fontawesome-solid-door-open:](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/){ .md-button target="_blank"}

    [Minikube Ingress :fontawesome-solid-door-open:](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/){ .md-button target="_blank"}

## References

```yaml
apiVersion: networking.k8s.io/v1beta1 # for versions before 1.14 use extensions/v1beta1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
    - host: hello-world.info
      http:
        paths:
          - path: /
            backend:
              serviceName: web
              servicePort: 8080
```

=== "OpenShift"

    ``` Bash title="View Ingress Status"
    oc describe clusteroperators/ingress
    ```

    ``` Bash title="Describe default Ingress Controller"
    oc describe --namespace=openshift-ingress-operator ingresscontroller/default
    ```

=== "Kubernetes"

    ``` Bash title="Describe default Ingress Controller"
    kubectl get pods -n kube-system | grep ingress
    ```
    ```
    kubectl create deployment web --image=quay.io/nginx/nginx-unprivileged:1.29
    ```
    ```
    kubectl expose deployment web --name=web --port 8080
    ```
    ```
    kubectl get svc web
    ```
    ```
    kubectl get ingress
    ```
    ```
    kubcetl describe ingress example-ingress
    ```
    ```
    curl hello-world.info --resolve hello-world.info:80:<ADDRESS>
    ```

## Activities

| Lab | Description |
| --- | ----------- |
| [Lab 11 - Routes & Ingress](../../labs/kubernetes/lab11/index.md) | Publish an app with an OpenShift Route and a Kubernetes Ingress |
