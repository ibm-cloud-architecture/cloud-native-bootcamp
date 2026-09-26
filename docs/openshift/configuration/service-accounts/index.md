---
tags:
  - Security
---

# Service Accounts

A service account provides an identity for processes that run in a Pod.

When you (a human) access the cluster (for example, using `oc` or `kubectl`), you are authenticated by the API server as a particular User Account, typically through your organization's identity provider. Processes in containers inside pods can also contact the API server. When they do, they are authenticated as a particular Service Account (for example, `default`).

User accounts are for humans. Service accounts are for processes, which run in pods.

User accounts are global: names are unique across the whole cluster. Service accounts are namespaced, and every namespace gets a `default` service account. What a service account may do is controlled with [RBAC](../rbac.md) roles and role bindings. On OpenShift, the service account also decides which [security context constraints](../security-contexts/index.md) a pod may use.

### Service account tokens

Kubernetes mounts a **short-lived, automatically rotated token** into every pod at `/var/run/secrets/kubernetes.io/serviceaccount/token`, bound to that pod's lifetime. Since Kubernetes 1.24 (OpenShift 4.11), long-lived token Secrets are no longer created automatically for service accounts.

- To get a token for use outside the cluster, for example in a CI system, request a time-limited one with `oc create token <service_account_name>`.
- Only create a long-lived `kubernetes.io/service-account-token` Secret, as shown in the example below, when a tool truly can't refresh tokens. Anyone who reads that Secret can act as the service account until the Secret is deleted.
- If a pod doesn't need to call the Kubernetes API, set `automountServiceAccountToken: false`.

## Resources

=== "OpenShift"

    [Service Accounts :fontawesome-solid-id-card:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/authentication_and_authorization/understanding-and-creating-service-accounts){ .md-button target="_blank"}

    [Using Service Accounts :fontawesome-solid-id-card:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/authentication_and_authorization/using-service-accounts){ .md-button target="_blank"}

=== "Kubernetes"

    [Service Accounts :fontawesome-solid-id-card:](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/){ .md-button target="_blank"}

    [Service Account Configuration :fontawesome-solid-id-card:](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/){ .md-button target="_blank"}

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
      image: quay.io/nginx/nginx-unprivileged:1.29
      ports:
        - containerPort: 8080
```

```yaml title="Long-lived token Secret (use only when necessary)"
apiVersion: v1
kind: Secret
metadata:
  name: build-robot-secret
  annotations:
    kubernetes.io/service-account.name: my-service-account
type: kubernetes.io/service-account-token
```

=== "OpenShift"

    ``` Bash title="Create a Service Account"
    oc create sa <service_account_name>
    ```

    ``` Bash title="View Service Account Details"
    oc describe sa <service_account_name>
    ```

    ``` Bash title="Get a short-lived token (1 hour)"
    oc create token <service_account_name> --duration=1h
    ```

=== "Kubernetes"

    ``` Bash title="Create a Service Account"
    kubectl create sa <service_account_name>
    ```

    ``` Bash title="View Service Account Details"
    kubectl describe sa <service_account_name>
    ```

    ``` Bash title="Get a short-lived token (1 hour)"
    kubectl create token <service_account_name> --duration=1h
    ```
