# Kubernetes Lab 10 - Network Policies

## Problem

Network policies allow you to control traffic flow between pods. In this lab, you will create a network policy that restricts access to a secure pod, allowing only pods with a specific label to connect.

## Prerequisites

Network policies require a CNI plugin that supports them (such as Calico, Cilium, or Weave Net). This lab uses Calico.

### Setup for Minikube

If using minikube, start it with CNI support and install Calico:

```bash
minikube start --network-plugin=cni
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml
kubectl -n kube-system get pods | grep calico-node
```

Wait for all calico-node pods to be Running before proceeding.

### Setup for OpenShift

OpenShift includes network policy support by default. No additional setup is required.

## Setup

### Step 1: Create the secured pod

Save the following to `secure-pod.yaml` and apply it:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: network-policy-secure-pod
  labels:
    app: secure-app
spec:
  containers:
    - name: nginx
      image: bitnami/nginx:1.25
      ports:
        - containerPort: 8080
```

```bash
kubectl apply -f secure-pod.yaml
```

### Step 2: Create the client pod (without the required label)

Save the following to `client-pod.yaml` and apply it:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: network-policy-client-pod
spec:
  containers:
    - name: busybox
      image: curlimages/curl:8.5.0
      command: ["/bin/sh", "-c", "while true; do sleep 3600; done"]
```

```bash
kubectl apply -f client-pod.yaml
```

### Step 3: Get the secure pod IP address

```bash
kubectl get pod network-policy-secure-pod -o jsonpath='{.status.podIP}'
```

Save this IP for testing connectivity.

### Step 4: Test connectivity before network policy

Before applying any network policy, verify the client can reach the secure pod:

```bash
kubectl exec network-policy-client-pod -- curl -s --max-time 5 http://<SECURE_POD_IP>:8080
```

You should see the nginx welcome page HTML.

## Tasks

1. **Create a NetworkPolicy** that:
   - Applies to pods with label `app: secure-app`
   - Only allows ingress traffic from pods with label `allow-access: "true"`
   - Denies all other ingress traffic

2. **Test that the policy works** by verifying:
   - The client pod (without the label) cannot access the secure pod
   - After adding the label, the client pod can access the secure pod

## Hints

- NetworkPolicy uses `podSelector` to select which pods the policy applies to
- Use `ingress.from.podSelector` to specify which pods can send traffic
- The `policyTypes` field should include `Ingress`

## Verification

### Test 1: Verify access is denied without the label

After applying the network policy, the client pod should NOT be able to reach the secure pod:

```bash
kubectl exec network-policy-client-pod -- curl -s --max-time 5 http://<SECURE_POD_IP>:8080
```

This should timeout or fail.

### Test 2: Add the required label to the client pod

```bash
kubectl label pod network-policy-client-pod allow-access=true
```

### Test 3: Verify access is now allowed

```bash
kubectl exec network-policy-client-pod -- curl -s --max-time 5 http://<SECURE_POD_IP>:8080
```

You should now see the nginx welcome page.

## Cleanup

```bash
kubectl delete pod network-policy-secure-pod network-policy-client-pod
kubectl delete networkpolicy my-network-policy
```
