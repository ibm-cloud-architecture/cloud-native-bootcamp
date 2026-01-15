# DaemonSets

A DaemonSet ensures that all (or some) nodes run a copy of a pod. As nodes are added to the cluster, pods are added to them. As nodes are removed from the cluster, those pods are garbage collected.

DaemonSets are typically used for cluster-wide services that need to run on every node.

## Common Use Cases

| Use Case | Examples |
|----------|----------|
| Logging Collectors | Fluentd, Filebeat, Logstash |
| Monitoring Agents | Prometheus Node Exporter, Datadog Agent |
| Storage Daemons | Ceph, GlusterFS |
| Network Plugins | Calico, Cilium, Weave Net |
| Security Agents | Falco, Twistlock |

## How DaemonSets Work

- When you create a DaemonSet, it automatically creates a pod on each node
- When a new node joins the cluster, a pod is scheduled on it
- When a node is removed, the pod is garbage collected
- Deleting a DaemonSet cleans up all the pods it created

## Resources

=== "OpenShift"

    [DaemonSets :fontawesome-solid-server:](https://docs.openshift.com/container-platform/4.17/nodes/jobs/nodes-pods-daemonsets.html){ .md-button target="_blank"}

=== "Kubernetes"

    [DaemonSets :fontawesome-solid-server:](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/){ .md-button target="_blank"}

    [Perform Rolling Update on DaemonSet :fontawesome-solid-server:](https://kubernetes.io/docs/tasks/manage-daemon/update-daemon-set/){ .md-button target="_blank"}

## References

_Basic DaemonSet for logging agent_

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: kube-system
  labels:
    app: fluentd
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      containers:
        - name: fluentd
          image: fluentd:v1.16
          resources:
            limits:
              memory: 200Mi
            requests:
              cpu: 100m
              memory: 200Mi
          volumeMounts:
            - name: varlog
              mountPath: /var/log
            - name: containers
              mountPath: /var/lib/docker/containers
              readOnly: true
      terminationGracePeriodSeconds: 30
      volumes:
        - name: varlog
          hostPath:
            path: /var/log
        - name: containers
          hostPath:
            path: /var/lib/docker/containers
```

_DaemonSet running only on specific nodes using nodeSelector_

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: gpu-monitor
spec:
  selector:
    matchLabels:
      app: gpu-monitor
  template:
    metadata:
      labels:
        app: gpu-monitor
    spec:
      nodeSelector:
        gpu: "true"
      containers:
        - name: gpu-monitor
          image: nvidia/dcgm-exporter:latest
```

_DaemonSet with tolerations to run on control plane nodes_

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      tolerations:
        - key: node-role.kubernetes.io/control-plane
          operator: Exists
          effect: NoSchedule
      containers:
        - name: node-exporter
          image: prom/node-exporter:latest
          ports:
            - containerPort: 9100
              hostPort: 9100
```

=== "OpenShift"

    ``` Bash title="Create DaemonSet"
    oc apply -f daemonset.yaml
    ```

    ``` Bash title="Get DaemonSets"
    oc get daemonsets -A
    ```

    ``` Bash title="Describe DaemonSet"
    oc describe daemonset fluentd -n kube-system
    ```

    ``` Bash title="Check DaemonSet Pods"
    oc get pods -l app=fluentd -o wide
    ```

    ``` Bash title="Delete DaemonSet"
    oc delete daemonset fluentd
    ```

=== "Kubernetes"

    ``` Bash title="Create DaemonSet"
    kubectl apply -f daemonset.yaml
    ```

    ``` Bash title="Get DaemonSets"
    kubectl get daemonsets -A
    ```

    ``` Bash title="Describe DaemonSet"
    kubectl describe daemonset fluentd -n kube-system
    ```

    ``` Bash title="Check DaemonSet Pods"
    kubectl get pods -l app=fluentd -o wide
    ```

    ``` Bash title="Delete DaemonSet"
    kubectl delete daemonset fluentd
    ```

## DaemonSet vs Deployment

| Feature | Deployment | DaemonSet |
|---------|------------|-----------|
| Replicas | User-defined count | One per node (automatic) |
| Scaling | Manual or HPA | Automatic with cluster |
| Node Coverage | Scheduled by kube-scheduler | Guaranteed per node |
| Use Case | Application workloads | Node-level services |
