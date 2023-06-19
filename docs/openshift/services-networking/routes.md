# Routes

(OpenShift Only)

Routes are Openshift objects that expose services for external clients to reach them by name.  

Routes can insecured or secured on creation using certificates.

The new route inherits the name from the service unless you specify one using the --name option.

## Resources

=== "OpenShift"

    [Routes :fontawesome-solid-globe:](https://docs.openshift.com/online/pro/dev_guide/routes.html){ .md-button target="_blank"}

    [Route Configuration :fontawesome-solid-globe:](https://docs.openshift.com/container-platform/4.13/networking/routes/route-configuration.html){ .md-button target="_blank"}

    [Secured Routes :fontawesome-solid-globe:](https://docs.openshift.com/container-platform/4.13/networking/routes/secured-routes.html){ .md-button target="_blank"}

## References

** Route Creation **
```
apiVersion: v1
kind: Route
metadata:
  name: frontend
spec:
  to:
    kind: Service
    name: frontend
```
** Secured Route Creation **
```
apiVersion: v1
kind: Route
metadata:
  name: frontend
spec:
  to:
    kind: Service
    name: frontend
  tls:
    termination: edge
```

## Commands
=== "OpenShift"

    ``` Bash title="Create Route from YAML"
    oc apply -f route.yaml
    ```

    ``` Bash title="Get Route"
    oc get route
    ```

    ``` Bash title="Describe Route"
    oc get route <route_name>
    ```

    ``` Bash title="Get Route YAML"
    oc get route <route_name> -o yaml
    ```