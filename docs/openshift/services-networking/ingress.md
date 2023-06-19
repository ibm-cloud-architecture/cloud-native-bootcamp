# Ingress

An API object that manages external access to the services in a cluster, typically HTTP.

Ingress can provide load balancing, SSL termination and name-based virtual hosting.

Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.

## Resources

=== "OpenShift"

    [Ingress Operator :fontawesome-solid-globe:](https://docs.openshift.com/container-platform/4.13/networking/ingress-operator.html){ .md-button target="_blank"}

    [Using Ingress Controllers :fontawesome-solid-globe:](https://docs.openshift.com/container-platform/4.13/networking/configuring_ingress_cluster_traffic/configuring-ingress-cluster-traffic-ingress-controller.html){ .md-button target="_blank"}

=== "Kubernetes"

    [Ingress :fontawesome-solid-globe:](https://kubernetes.io/docs/concepts/services-networking/ingress/){ .md-button target="_blank"}

    [Ingress Controllers :fontawesome-solid-globe:](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/){ .md-button target="_blank"}

    [Minikube Ingress :fontawesome-solid-globe:](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/){ .md-button target="_blank"}

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
    kubectl create deployment web --image=bitnami/nginx
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

| Task                            | Description         | Link        |
| --------------------------------| ------------------  |:----------- |
| *** Try It Yourself ***                         |         |         | 
| IKS Ingress Controller | Configure Ingress on Free IKS Cluster | [Setting IKS Ingress](../../labs/kubernetes/ingress-iks/index.md) |