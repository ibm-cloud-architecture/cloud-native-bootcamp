# Service Accounts

A service account provides an identity for processes that run in a Pod.

When you (a human) access the cluster (for example, using kubectl), you are authenticated by the apiserver as a particular User Account (currently this is usually admin, unless your cluster administrator has customized your cluster). Processes in containers inside pods can also contact the apiserver. When they do, they are authenticated as a particular Service Account (for example, default).

User accounts are for humans. Service accounts are for processes, which run in pods.

User accounts are intended to be global. Names must be unique across all namespaces of a cluster, future user resource will not be namespaced. Service accounts are namespaced.

## Resources

**OpenShift**

- [Service Accounts](https://docs.openshift.com/container-platform/4.13/authentication/understanding-and-creating-service-accounts.html){:target="_blank"}
- [Using Service Accounts](https://docs.openshift.com/container-platform/4.13/authentication/using-service-accounts-in-applications.html){:target="_blank"}

**IKS**

- [Service Accounts](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/){:target="_blank"}
- [Service Account Configuration](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/){:target="_blank"}

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

=== "Openshift"

    ``` Bash title="Create a Service Account"
    oc create sa <service_account_name>
    ```

    ``` Bash title="View Service Account Details"
    oc describe sa <service_account_name>
    ```

=== "Kubernetes"

    ``` Bash title="Create a Service Account"
    kubectl create sa <service_account_name>
    ```

    ``` Bash title="View Service Account Details"
    kubectl describe sa <service_account_name>
    ```