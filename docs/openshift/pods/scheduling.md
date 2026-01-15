# Taints, Tolerations & Node Affinity

Kubernetes provides several mechanisms to control which nodes pods can be scheduled on. These features help you ensure workloads run on appropriate nodes and enable advanced scheduling scenarios.

## Taints and Tolerations

**Taints** are applied to nodes and repel pods from being scheduled on them. **Tolerations** are applied to pods and allow (but don't require) pods to be scheduled on nodes with matching taints.

### Taint Effects

| Effect | Description |
|--------|-------------|
| `NoSchedule` | Pods without matching toleration won't be scheduled |
| `PreferNoSchedule` | Scheduler tries to avoid placing pods, but not guaranteed |
| `NoExecute` | Evicts existing pods and prevents new scheduling |

### Common Use Cases

- **Dedicated Nodes**: Reserve nodes for specific workloads (GPU, high-memory)
- **Node Maintenance**: Drain nodes for updates without affecting other workloads
- **Specialized Hardware**: Ensure only appropriate workloads use expensive resources

## Node Affinity

Node Affinity allows you to constrain which nodes a pod can be scheduled on based on node labels. It's more expressive than `nodeSelector`.

### Affinity Types

| Type | Description |
|------|-------------|
| `requiredDuringSchedulingIgnoredDuringExecution` | Hard requirement - pod won't schedule if not met |
| `preferredDuringSchedulingIgnoredDuringExecution` | Soft preference - scheduler tries to meet it |

## Resources

=== "OpenShift"

    [Controlling Pod Placement :fontawesome-solid-sitemap:](https://docs.openshift.com/container-platform/4.17/nodes/scheduling/nodes-scheduler-taints-tolerations.html){ .md-button target="_blank"}

    [Node Affinity :fontawesome-solid-sitemap:](https://docs.openshift.com/container-platform/4.17/nodes/scheduling/nodes-scheduler-node-affinity.html){ .md-button target="_blank"}

=== "Kubernetes"

    [Taints and Tolerations :fontawesome-solid-sitemap:](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/){ .md-button target="_blank"}

    [Node Affinity :fontawesome-solid-sitemap:](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity){ .md-button target="_blank"}

## References

### Taints and Tolerations

_Adding a taint to a node_

```bash
kubectl taint nodes node1 dedicated=gpu:NoSchedule
```

_Pod with toleration_

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  containers:
    - name: cuda-app
      image: nvidia/cuda:latest
  tolerations:
    - key: "dedicated"
      operator: "Equal"
      value: "gpu"
      effect: "NoSchedule"
```

_Tolerate all taints with a specific key_

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: tolerant-pod
spec:
  containers:
    - name: app
      image: nginx
  tolerations:
    - key: "dedicated"
      operator: "Exists"
      effect: "NoSchedule"
```

_Toleration for control plane nodes_

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: control-plane-pod
spec:
  containers:
    - name: app
      image: nginx
  tolerations:
    - key: "node-role.kubernetes.io/control-plane"
      operator: "Exists"
      effect: "NoSchedule"
```

### Node Affinity

_Required node affinity (hard requirement)_

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: affinity-pod
spec:
  containers:
    - name: app
      image: nginx
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: topology.kubernetes.io/zone
                operator: In
                values:
                  - us-east-1a
                  - us-east-1b
```

_Preferred node affinity (soft preference)_

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: preferred-affinity-pod
spec:
  containers:
    - name: app
      image: nginx
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          preference:
            matchExpressions:
              - key: node-type
                operator: In
                values:
                  - high-memory
        - weight: 50
          preference:
            matchExpressions:
              - key: node-type
                operator: In
                values:
                  - standard
```

_Combined taints, tolerations, and affinity_

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gpu-workload
spec:
  replicas: 3
  selector:
    matchLabels:
      app: gpu-workload
  template:
    metadata:
      labels:
        app: gpu-workload
    spec:
      containers:
        - name: cuda-app
          image: nvidia/cuda:latest
          resources:
            limits:
              nvidia.com/gpu: 1
      tolerations:
        - key: "nvidia.com/gpu"
          operator: "Exists"
          effect: "NoSchedule"
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: accelerator
                    operator: In
                    values:
                      - nvidia-tesla-v100
```

## Pod Anti-Affinity

Pod anti-affinity ensures pods are spread across different nodes or zones for high availability.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-server
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-server
  template:
    metadata:
      labels:
        app: web-server
    spec:
      containers:
        - name: nginx
          image: nginx
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: app
                    operator: In
                    values:
                      - web-server
              topologyKey: "kubernetes.io/hostname"
```

=== "OpenShift"

    ``` Bash title="Add Taint to Node"
    oc adm taint nodes node1 dedicated=gpu:NoSchedule
    ```

    ``` Bash title="Remove Taint from Node"
    oc adm taint nodes node1 dedicated=gpu:NoSchedule-
    ```

    ``` Bash title="View Node Taints"
    oc describe node node1 | grep -A5 Taints
    ```

    ``` Bash title="Label a Node"
    oc label nodes node1 node-type=high-memory
    ```

    ``` Bash title="View Node Labels"
    oc get nodes --show-labels
    ```

=== "Kubernetes"

    ``` Bash title="Add Taint to Node"
    kubectl taint nodes node1 dedicated=gpu:NoSchedule
    ```

    ``` Bash title="Remove Taint from Node"
    kubectl taint nodes node1 dedicated=gpu:NoSchedule-
    ```

    ``` Bash title="View Node Taints"
    kubectl describe node node1 | grep -A5 Taints
    ```

    ``` Bash title="Label a Node"
    kubectl label nodes node1 node-type=high-memory
    ```

    ``` Bash title="View Node Labels"
    kubectl get nodes --show-labels
    ```

## Comparison

| Feature | Use Case | Scope |
|---------|----------|-------|
| **nodeSelector** | Simple label matching | Node labels |
| **Taints/Tolerations** | Repel pods from nodes | Node-level |
| **Node Affinity** | Complex node selection rules | Node labels |
| **Pod Affinity** | Co-locate pods together | Pod labels |
| **Pod Anti-Affinity** | Spread pods apart | Pod labels |
