# Routes

(OpenShift Only)

Routes are Openshift objects that expose services for external clients to reach them by name.  

Routes can insecured or secured on creation using certificates.

The new route inherits the name from the service unless you specify one using the --name option.

## Resources

**OpenShift**
- [Routes](https://docs.openshift.com/online/pro/dev_guide/routes.html)
- [Route Configuration](https://docs.openshift.com/container-platform/4.3/networking/routes/route-configuration.html)
- [Secured Routes](https://docs.openshift.com/container-platform/4.3/networking/routes/secured-routes.html)

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

### Commands
<Tabs>
<Tab label="OpenShift">

** Create Route from YAML **
```
oc apply -f route.yaml
```
** Get Route **
```
oc get route
```
** Describe Route **
```
oc get route <route-name>
```
** Get Route YAML **
```
oc get route <route-name> -o yaml
```

</Tab>
</Tabs>