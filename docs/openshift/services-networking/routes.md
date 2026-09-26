---
tags:
  - Networking
  - OpenShift only
---

# Routes

**_OpenShift Only_**

Routes are OpenShift objects that expose a Service at a hostname, so clients outside the cluster can reach it. The cluster's router (HAProxy-based) receives the traffic on ports 80 and 443 and forwards it to the Service's pods.

- A Route can be **unsecured** (HTTP) or **secured** with TLS using `edge`, `passthrough` or `reencrypt` termination.
- If you don't set a hostname, OpenShift generates one: `<route-name>-<project>.<apps-domain>`.
- `oc expose service` creates a Route that takes its name from the Service, unless you pass `--name`.
- Routes can split traffic between several Services by weight, which is useful for blue-green and canary releases.

For portable manifests you can also use a Kubernetes [Ingress](ingress.md), which OpenShift converts into a Route.

## Resources

=== "OpenShift"

    [Routes :fontawesome-solid-route:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/ingress_and_load_balancing/routes){ .md-button target="_blank"}

## References

```yaml title="Route"
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: frontend
spec:
  to:
    kind: Service
    name: frontend
  port:
    targetPort: 8080
```

```yaml title="Secured (edge) Route that redirects HTTP to HTTPS"
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: frontend-secure
spec:
  to:
    kind: Service
    name: frontend
  port:
    targetPort: 8080
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
```

```yaml title="Canary: send 10% of traffic to a new version"
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: frontend-canary
spec:
  to:
    kind: Service
    name: frontend
    weight: 90
  alternateBackends:
    - kind: Service
      name: frontend-v2
      weight: 10
  port:
    targetPort: 8080
```

## Commands

=== "OpenShift"

    ``` Bash title="Create Route from YAML"
    oc apply -f route.yaml
    ```

    ``` Bash title="Create a Route for a Service"
    oc expose service frontend
    ```

    ``` Bash title="Create an edge-terminated TLS Route"
    oc create route edge frontend-secure --service=frontend --insecure-policy=Redirect
    ```

    ``` Bash title="Get the Route's URL"
    oc get route frontend -o jsonpath='{.spec.host}{"\n"}'
    ```

    ``` Bash title="Get Route"
    oc get route
    ```

    ``` Bash title="Describe Route"
    oc describe route <route_name>
    ```

    ``` Bash title="Get Route YAML"
    oc get route <route_name> -o yaml
    ```
