# Kubernetes Lab 10 - Network Policies

## Solution

### Step 1: Create the NetworkPolicy

Save the following to `network-policy.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-network-policy
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

Apply the policy:

```bash
kubectl apply -f network-policy.yaml
```

### Understanding the Policy

- `podSelector.matchLabels.app: secure-app` - This policy applies to pods with the label `app: secure-app`
- `policyTypes: [Ingress]` - This policy controls incoming traffic
- `ingress.from.podSelector.matchLabels.allow-access: "true"` - Only allow traffic from pods with this label

### Step 2: Test that access is blocked

Get the secure pod IP:

```bash
SECURE_POD_IP=$(kubectl get pod network-policy-secure-pod -o jsonpath='{.status.podIP}')
```

Try to access from the client pod (should fail/timeout):

```bash
kubectl exec network-policy-client-pod -- curl -s --max-time 5 http://$SECURE_POD_IP:8080
```

### Step 3: Add the required label

```bash
kubectl label pod network-policy-client-pod allow-access=true
```

### Step 4: Test that access is now allowed

```bash
kubectl exec network-policy-client-pod -- curl -s --max-time 5 http://$SECURE_POD_IP:8080
```

You should now see the nginx welcome page HTML.

### Verify the network policy

```bash
kubectl get networkpolicy my-network-policy
kubectl describe networkpolicy my-network-policy
```
