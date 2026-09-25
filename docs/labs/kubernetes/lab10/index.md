# Lab 10 - Network Policies

<span class="lab-badge">30 min</span> <span class="lab-badge">Intermediate</span>

## Problem

By default, every pod can talk to every other pod. A NetworkPolicy restricts which traffic is allowed. In this lab you'll lock down a secure pod so that only pods with a specific label can connect to it.

!!! info "Cluster support"
    NetworkPolicies are enforced by the cluster's network plugin. OpenShift's default network plugin, OVN-Kubernetes, supports them with no extra setup. On local Kubernetes, kind's default network plugin supports them too. On minikube, start with `minikube start --cni=calico`.

## Setup

```bash
oc new-project lab10
```

### Create the secure pod

```yaml title="secure-pod.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: network-policy-secure-pod
  labels:
    app: secure-app
spec:
  containers:
    - name: nginx
      image: quay.io/nginx/nginx-unprivileged:1.29
      ports:
        - containerPort: 8080
```

### Create the client pod (without the required label)

```yaml title="client-pod.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: network-policy-client-pod
spec:
  containers:
    - name: client
      image: registry.access.redhat.com/ubi9/ubi-minimal
      command: ["sleep", "infinity"]
```

```bash
oc apply -f secure-pod.yaml -f client-pod.yaml
oc wait --for=condition=Ready pod/network-policy-secure-pod pod/network-policy-client-pod
```

### Test connectivity before you add a policy

```bash
SECURE_POD_IP=$(oc get pod network-policy-secure-pod -o jsonpath='{.status.podIP}')
oc exec network-policy-client-pod -- curl -s --max-time 5 "http://${SECURE_POD_IP}:8080" | grep "<title>"
```

You should see `<title>Welcome to nginx!</title>`.

## Tasks

1. **Create a NetworkPolicy** named `secure-app-policy` that:
    - applies to pods with the label `app: secure-app`
    - allows ingress traffic only from pods with the label `allow-access: "true"`
    - denies all other ingress traffic
2. **Test the policy**:
    - the client pod, which doesn't have the label, can no longer reach the secure pod
    - after you add the label, the client pod can reach it again

## Hints

- A NetworkPolicy's `podSelector` chooses the pods the policy applies to.
- `ingress[].from[].podSelector` chooses which pods may send traffic.
- Once a pod is selected by any policy with `policyTypes: [Ingress]`, all ingress traffic not explicitly allowed is denied.

## Verification

1. Without the label, the connection times out:

    ```bash
    oc exec network-policy-client-pod -- curl -s --max-time 5 "http://${SECURE_POD_IP}:8080" \
      || echo "Connection blocked"
    ```

2. Add the label to the client pod:

    ```bash
    oc label pod network-policy-client-pod allow-access=true
    ```

3. The connection now succeeds:

    ```bash
    oc exec network-policy-client-pod -- curl -s --max-time 5 "http://${SECURE_POD_IP}:8080" | grep "<title>"
    ```

## Cleanup

```bash
oc delete project lab10
```
