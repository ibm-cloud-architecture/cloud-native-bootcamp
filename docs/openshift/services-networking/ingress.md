# Ingress

An API object that manages external access to the services in a cluster, typically HTTP.

Ingress can provide load balancing, SSL termination and name-based virtual hosting.

Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource. An Ingress does nothing on its own: an **ingress controller** running in the cluster reads the Ingress objects and configures a proxy or load balancer.

!!! info "Ingress on OpenShift"
    OpenShift's built-in router (the default IngressController) serves both **Routes** and standard **Ingress** objects. When you create an Ingress, OpenShift generates a matching Route automatically, so Ingress manifests from other Kubernetes distributions work unchanged. See [Routes](routes.md) for the OpenShift-native API.

!!! note "Ingress and Gateway API"
    The Ingress API is stable but frozen: it gets no new features. Its successor is **[Gateway API](https://gateway-api.sigs.k8s.io/)**, which is more expressive (traffic splitting, header matching, multiple protocols) and separates the roles of cluster operators and app developers. The popular community Ingress NGINX controller was [retired in 2026](https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/). For new work on upstream Kubernetes, prefer Gateway API. OpenShift supports Gateway API from version 4.19.

## Resources

=== "OpenShift"

    [Ingress Operator :fontawesome-solid-door-open:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/ingress_and_load_balancing/index){ .md-button target="_blank"}

    [Using Ingress Controllers :fontawesome-solid-door-open:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/ingress_and_load_balancing/configuring-ingress-cluster-traffic){ .md-button target="_blank"}

=== "Kubernetes"

    [Ingress :fontawesome-solid-door-open:](https://kubernetes.io/docs/concepts/services-networking/ingress/){ .md-button target="_blank"}

    [Ingress Controllers :fontawesome-solid-door-open:](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/){ .md-button target="_blank"}

    [Gateway API :fontawesome-solid-door-open:](https://kubernetes.io/docs/concepts/services-networking/gateway/){ .md-button target="_blank"}

## References

```yaml title="Ingress"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
spec:
  # ingressClassName: openshift-default  # optional; the cluster default is used if omitted
  rules:
    - host: hello-world.apps.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web
                port:
                  number: 8080
  tls:                      # optional: terminate TLS for this host
    - hosts:
        - hello-world.apps.example.com
```

```yaml title="The same route with Gateway API"
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: example-route
spec:
  parentRefs:
    - name: example-gateway        # a Gateway created by the platform team
      namespace: gateway-system
  hostnames:
    - hello-world.apps.example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: web
          port: 8080
```

=== "OpenShift"

    ``` Bash title="Deploy an app and a Service for it"
    oc create deployment web --image=quay.io/nginx/nginx-unprivileged:1.29 --port=8080
    oc expose deployment web --port=8080
    ```

    ``` Bash title="Create the Ingress and see the Route generated from it"
    oc apply -f ingress.yaml
    oc get ingress
    oc get routes
    ```

    ``` Bash title="View the ingress operator and default controller"
    oc describe clusteroperators/ingress
    oc describe --namespace=openshift-ingress-operator ingresscontroller/default
    ```

=== "Kubernetes"

    ``` Bash title="Check which ingress controllers (IngressClasses) are installed"
    kubectl get ingressclass
    ```

    ``` Bash title="Deploy an app and a Service for it"
    kubectl create deployment web --image=quay.io/nginx/nginx-unprivileged:1.29 --port=8080
    kubectl expose deployment web --port=8080
    ```

    ``` Bash title="Create and inspect the Ingress"
    kubectl apply -f ingress.yaml
    kubectl get ingress
    kubectl describe ingress example-ingress
    ```

    ``` Bash title="Test it before DNS exists, using the ADDRESS from kubectl get ingress"
    curl http://hello-world.apps.example.com --resolve hello-world.apps.example.com:80:<ADDRESS>
    ```

## Activities

| Lab | Description |
| --- | ----------- |
| [Lab 11 - Routes & Ingress](../../labs/kubernetes/lab11/index.md) | Publish an app with an OpenShift Route and a Kubernetes Ingress |
