# Role-Based Access Control (RBAC)

Role-Based Access Control (RBAC) is a method of regulating access to resources based on the roles of individual users. RBAC uses the `rbac.authorization.k8s.io` API group to drive authorization decisions, allowing you to dynamically configure policies through the Kubernetes API.

## RBAC Components

RBAC authorization uses four kinds of Kubernetes objects:

| Object | Scope | Description |
|--------|-------|-------------|
| **Role** | Namespace | Grants permissions within a specific namespace |
| **ClusterRole** | Cluster-wide | Grants permissions cluster-wide or to cluster-scoped resources |
| **RoleBinding** | Namespace | Binds a Role or ClusterRole to users within a namespace |
| **ClusterRoleBinding** | Cluster-wide | Binds a ClusterRole to users across the entire cluster |

## How RBAC Works

1. **Roles/ClusterRoles** define *what* actions can be performed on *which* resources
2. **RoleBindings/ClusterRoleBindings** define *who* can perform those actions
3. Permissions are purely additive (there are no "deny" rules)

## Resources

=== "OpenShift"

    [RBAC Overview :fontawesome-solid-shield-halved:](https://docs.openshift.com/container-platform/4.17/authentication/using-rbac.html){ .md-button target="_blank"}

    [Default Cluster Roles :fontawesome-solid-shield-halved:](https://docs.openshift.com/container-platform/4.17/authentication/using-rbac.html#default-roles_using-rbac){ .md-button target="_blank"}

=== "Kubernetes"

    [RBAC Authorization :fontawesome-solid-shield-halved:](https://kubernetes.io/docs/reference/access-authn-authz/rbac/){ .md-button target="_blank"}

    [Using RBAC :fontawesome-solid-shield-halved:](https://kubernetes.io/docs/admin/authorization/rbac/){ .md-button target="_blank"}

## References

_Role - Grants read access to pods in a namespace_

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "watch", "list"]
```

_RoleBinding - Binds the Role to a user_

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
  - kind: User
    name: jane
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

_ClusterRole - Grants read access to secrets cluster-wide_

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: secret-reader
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "watch", "list"]
```

_ClusterRoleBinding - Binds ClusterRole to a group_

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-secrets-global
subjects:
  - kind: Group
    name: developers
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

_Role for a ServiceAccount with deployment permissions_

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: deployment-manager
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: deployment-manager-binding
  namespace: production
subjects:
  - kind: ServiceAccount
    name: deploy-bot
    namespace: production
roleRef:
  kind: Role
  name: deployment-manager
  apiGroup: rbac.authorization.k8s.io
```

## Common Verbs

| Verb | Description |
|------|-------------|
| `get` | Read a specific resource |
| `list` | List resources of a type |
| `watch` | Watch for changes to resources |
| `create` | Create new resources |
| `update` | Update existing resources |
| `patch` | Partially update resources |
| `delete` | Delete resources |
| `deletecollection` | Delete multiple resources |

## Default ClusterRoles

| Role | Description |
|------|-------------|
| `cluster-admin` | Full access to all resources |
| `admin` | Full access within a namespace |
| `edit` | Read/write access to most resources in a namespace |
| `view` | Read-only access to most resources in a namespace |

=== "OpenShift"

    ``` Bash title="Get Roles in Namespace"
    oc get roles
    ```

    ``` Bash title="Get ClusterRoles"
    oc get clusterroles
    ```

    ``` Bash title="Get RoleBindings"
    oc get rolebindings
    ```

    ``` Bash title="Describe a Role"
    oc describe role pod-reader
    ```

    ``` Bash title="Check if User Can Perform Action"
    oc auth can-i create pods --as=jane
    ```

    ``` Bash title="Add Role to User (OpenShift)"
    oc adm policy add-role-to-user edit jane -n myproject
    ```

    ``` Bash title="Add Cluster Role to User"
    oc adm policy add-cluster-role-to-user cluster-admin admin-user
    ```

=== "Kubernetes"

    ``` Bash title="Get Roles in Namespace"
    kubectl get roles
    ```

    ``` Bash title="Get ClusterRoles"
    kubectl get clusterroles
    ```

    ``` Bash title="Get RoleBindings"
    kubectl get rolebindings
    ```

    ``` Bash title="Describe a Role"
    kubectl describe role pod-reader
    ```

    ``` Bash title="Check if User Can Perform Action"
    kubectl auth can-i create pods --as=jane
    ```

    ``` Bash title="Check All Permissions for User"
    kubectl auth can-i --list --as=jane
    ```

    ``` Bash title="Create Role Imperatively"
    kubectl create role pod-reader --verb=get,list,watch --resource=pods
    ```

    ``` Bash title="Create RoleBinding Imperatively"
    kubectl create rolebinding read-pods --role=pod-reader --user=jane
    ```
