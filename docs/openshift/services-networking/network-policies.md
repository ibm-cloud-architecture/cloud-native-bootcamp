# Network Policies

Network Policies are Kubernetes resources that control traffic flow between pods and network endpoints. By default, pods are non-isolated and accept traffic from any source. Network Policies allow you to specify how pods can communicate with each other and with other network endpoints.

## How Network Policies Work

- Network Policies are namespace-scoped
- They use labels to select pods and define rules for traffic
- Policies are additive - if any policy allows a connection, it is allowed
- If no policies select a pod, all traffic is allowed (default behavior)
- Once a pod is selected by any Network Policy, it rejects all traffic not explicitly allowed

## Policy Types

| Type | Description |
|------|-------------|
| **Ingress** | Controls incoming traffic to selected pods |
| **Egress** | Controls outgoing traffic from selected pods |

## Resources

=== "OpenShift"

    [Network Policies :fontawesome-solid-network-wired:](https://docs.openshift.com/container-platform/4.17/networking/network_policy/about-network-policy.html){ .md-button target="_blank"}

    [Creating Network Policies :fontawesome-solid-network-wired:](https://docs.openshift.com/container-platform/4.17/networking/network_policy/creating-network-policy.html){ .md-button target="_blank"}

=== "Kubernetes"

    [Network Policies :fontawesome-solid-network-wired:](https://kubernetes.io/docs/concepts/services-networking/network-policies/){ .md-button target="_blank"}

    [Declare Network Policy :fontawesome-solid-network-wired:](https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/){ .md-button target="_blank"}

## References

_Default Deny All Ingress Traffic_

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: production
spec:
  podSelector: {}  # Selects all pods in namespace
  policyTypes:
    - Ingress
```

_Default Deny All Egress Traffic_

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-egress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
    - Egress
```

_Allow Traffic from Specific Pods_

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - protocol: TCP
          port: 8080
```

_Allow Traffic from Specific Namespace_

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-monitoring
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: monitoring
```

_Allow Egress to Specific CIDR and DNS_

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-external-egress
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
    - Egress
  egress:
    # Allow DNS
    - to: []
      ports:
        - protocol: UDP
          port: 53
    # Allow specific external IPs
    - to:
        - ipBlock:
            cidr: 10.0.0.0/8
            except:
              - 10.0.1.0/24
      ports:
        - protocol: TCP
          port: 443
```

_Complete Example: Database Access Policy_

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: database
      tier: backend
  policyTypes:
    - Ingress
    - Egress
  ingress:
    # Only allow backend pods to connect
    - from:
        - podSelector:
            matchLabels:
              tier: backend
        - namespaceSelector:
            matchLabels:
              environment: production
      ports:
        - protocol: TCP
          port: 5432
  egress:
    # Allow DNS lookups
    - to: []
      ports:
        - protocol: UDP
          port: 53
```

=== "OpenShift"

    ``` Bash title="Create Network Policy"
    oc apply -f network-policy.yaml
    ```

    ``` Bash title="Get Network Policies"
    oc get networkpolicies
    ```

    ``` Bash title="Describe Network Policy"
    oc describe networkpolicy allow-frontend-to-backend
    ```

    ``` Bash title="Delete Network Policy"
    oc delete networkpolicy default-deny-ingress
    ```

    ``` Bash title="Get Network Policies in All Namespaces"
    oc get networkpolicies -A
    ```

=== "Kubernetes"

    ``` Bash title="Create Network Policy"
    kubectl apply -f network-policy.yaml
    ```

    ``` Bash title="Get Network Policies"
    kubectl get networkpolicies
    ```

    ``` Bash title="Describe Network Policy"
    kubectl describe networkpolicy allow-frontend-to-backend
    ```

    ``` Bash title="Delete Network Policy"
    kubectl delete networkpolicy default-deny-ingress
    ```

    ``` Bash title="Get Network Policies in All Namespaces"
    kubectl get networkpolicies -A
    ```

## Best Practices

1. **Start with Default Deny** - Create a default deny policy, then explicitly allow required traffic
2. **Use Labels Consistently** - Establish a labeling convention for apps, tiers, and environments
3. **Test Policies** - Verify policies work as expected before applying to production
4. **Document Policies** - Keep track of what traffic flows are allowed and why
5. **Monitor Traffic** - Use network monitoring tools to detect policy violations

## Activities

| Task                  | Description                                                            | Link                                                        |
| --------------------- | ---------------------------------------------------------------------- | :---------------------------------------------------------- |
| **_Try It Yourself_** |                                                                        |                                                             |
| Network Policies      | Create a policy to allow client pods with labels to access secure pod. | [Network Policies](../../labs/kubernetes/lab10/index.md) |
