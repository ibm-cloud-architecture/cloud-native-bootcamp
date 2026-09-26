---
tags:
  - Solution
  - Networking
  - Security
---

# Lab 10 Solution - Network Policies

```yaml title="secure-app-policy.yaml"
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: secure-app-policy
spec:
  podSelector:
    matchLabels:
      app: secure-app
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              allow-access: "true"
```

```bash
oc apply -f secure-app-policy.yaml
oc describe networkpolicy secure-app-policy
```

## How the policy works

| Field | Meaning |
| --- | --- |
| `podSelector.matchLabels.app: secure-app` | The policy applies to pods labelled `app: secure-app`. |
| `policyTypes: [Ingress]` | The policy controls **incoming** traffic to those pods. Outgoing traffic is unaffected. |
| `ingress[0].from[0].podSelector` | Only pods labelled `allow-access: "true"` **in the same namespace** may connect. |

## Test it

```bash
SECURE_POD_IP=$(oc get pod network-policy-secure-pod -o jsonpath='{.status.podIP}')

# Blocked
oc exec network-policy-client-pod -- curl -s --max-time 5 "http://${SECURE_POD_IP}:8080" \
  || echo "Connection blocked"

# Allowed after labelling the client
oc label pod network-policy-client-pod allow-access=true
oc exec network-policy-client-pod -- curl -s --max-time 5 "http://${SECURE_POD_IP}:8080" | grep "<title>"
```

!!! tip "Other namespaces"
    To also allow clients from other namespaces, add a `namespaceSelector` to the same `from` entry, for example `kubernetes.io/metadata.name: frontend`. A `podSelector` and `namespaceSelector` in the **same** entry must both match. In **separate** entries, either one is enough.
