# Service Accounts

A service account provides an identity for processes that run in a Pod.

When you (a human) access the cluster (for example, using kubectl), you are authenticated by the apiserver as a particular User Account (currently this is usually admin, unless your cluster administrator has customized your cluster). Processes in containers inside pods can also contact the apiserver. When they do, they are authenticated as a particular Service Account (for example, default).

User accounts are for humans. Service accounts are for processes, which run in pods.

User accounts are intended to be global. Names must be unique across all namespaces of a cluster, future user resource will not be namespaced. Service accounts are namespaced.

## Resources

**OpenShift**

- [Service Accounts](https://docs.openshift.com/container-platform/4.3/authentication/understanding-and-creating-service-accounts.html)
- [Using Service Accounts](https://docs.openshift.com/container-platform/4.3/authentication/using-service-accounts-in-applications.html)

**IKS**

- [Service Accounts](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/)
- [Service Account Configuration](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)

## References

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: my-service-account
  containers:
  - name: my-app
    image: bitnami/nginx
    ports:
      - containerPort: 8080
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: build-robot-secret
  annotations:
    kubernetes.io/service-account.name: my-service-account
type: kubernetes.io/service-account-token
```

<Tabs>
<Tab label="OpenShift">

** Creating a ServiceAccount**
```
oc create sa <service_account_name>
```
** View ServiceAccount Details **
```
oc describe sa <service_account_name>
```

</Tab>

<Tab label="IKS">

** Create a ServiceAccount **
```
kubectl create sa <service_account_name>
```
** View ServiceAccount Details **
```
kubectl describe sa <service_account_name>
```

</Tab>

</Tabs>