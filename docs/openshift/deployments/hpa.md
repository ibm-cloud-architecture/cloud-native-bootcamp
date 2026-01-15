# Horizontal Pod Autoscaler (HPA)

The Horizontal Pod Autoscaler automatically scales the number of pods in a deployment, replica set, or stateful set based on observed CPU utilization, memory usage, or custom metrics. This allows your applications to handle varying loads efficiently.

## How HPA Works

1. HPA continuously monitors the metrics of pods in the target workload
2. It calculates the desired number of replicas based on the metrics and target values
3. The controller adjusts the replica count to match demand
4. Scale-up and scale-down happen automatically within configured bounds

## Metrics Types

| Metric Type | Description | Example |
|-------------|-------------|---------|
| **Resource** | CPU or memory utilization | `cpu`, `memory` |
| **Pods** | Custom metrics from pods | `requests_per_second` |
| **Object** | Metrics from other Kubernetes objects | `queue_length` from a Service |
| **External** | Metrics from outside the cluster | Cloud provider metrics |

## Resources

=== "OpenShift"

    [Horizontal Pod Autoscaler :fontawesome-solid-chart-line:](https://docs.openshift.com/container-platform/4.17/nodes/pods/nodes-pods-autoscaling.html){ .md-button target="_blank"}

    [Custom Metrics Autoscaler :fontawesome-solid-chart-line:](https://docs.openshift.com/container-platform/4.17/nodes/pods/nodes-pods-autoscaling-custom.html){ .md-button target="_blank"}

=== "Kubernetes"

    [Horizontal Pod Autoscaling :fontawesome-solid-chart-line:](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/){ .md-button target="_blank"}

    [HPA Walkthrough :fontawesome-solid-chart-line:](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/){ .md-button target="_blank"}

## Prerequisites

For HPA to work with CPU and memory metrics, you need:

- **Metrics Server** installed in your cluster (provides resource metrics)
- **Resource requests** defined on your containers (HPA uses these as the baseline)

## References

_Basic HPA based on CPU_

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

_HPA with CPU and Memory_

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 3
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 75
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

_HPA with Scaling Behavior_

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: controlled-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300  # Wait 5 min before scaling down
      policies:
        - type: Percent
          value: 10
          periodSeconds: 60  # Scale down max 10% per minute
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
        - type: Percent
          value: 100
          periodSeconds: 15  # Can double every 15 seconds
        - type: Pods
          value: 4
          periodSeconds: 15  # Or add 4 pods every 15 seconds
      selectPolicy: Max
```

_Deployment with Resource Requests (required for HPA)_

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
        - name: web
          image: nginx
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
          ports:
            - containerPort: 80
```

=== "OpenShift"

    ``` Bash title="Create HPA Imperatively"
    oc autoscale deployment web-app --min=2 --max=10 --cpu-percent=70
    ```

    ``` Bash title="Get HPAs"
    oc get hpa
    ```

    ``` Bash title="Describe HPA"
    oc describe hpa web-app-hpa
    ```

    ``` Bash title="Watch HPA Status"
    oc get hpa -w
    ```

    ``` Bash title="Delete HPA"
    oc delete hpa web-app-hpa
    ```

    ``` Bash title="Check Metrics Server"
    oc top pods
    ```

=== "Kubernetes"

    ``` Bash title="Create HPA Imperatively"
    kubectl autoscale deployment web-app --min=2 --max=10 --cpu-percent=70
    ```

    ``` Bash title="Get HPAs"
    kubectl get hpa
    ```

    ``` Bash title="Describe HPA"
    kubectl describe hpa web-app-hpa
    ```

    ``` Bash title="Watch HPA Status"
    kubectl get hpa -w
    ```

    ``` Bash title="Delete HPA"
    kubectl delete hpa web-app-hpa
    ```

    ``` Bash title="Check Metrics Server"
    kubectl top pods
    ```

## Understanding HPA Output

When you run `kubectl get hpa`, you'll see output like:

```
NAME          REFERENCE              TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
web-app-hpa   Deployment/web-app    45%/70%   2         10        3          5m
```

| Column | Description |
|--------|-------------|
| TARGETS | Current/Target utilization (45% current, 70% target) |
| MINPODS | Minimum replicas |
| MAXPODS | Maximum replicas |
| REPLICAS | Current number of pods |

## Best Practices

1. **Set Resource Requests** - Always define CPU/memory requests on containers
2. **Start Conservative** - Begin with higher target utilization and adjust
3. **Use Stabilization Windows** - Prevent thrashing with scale-down delays
4. **Monitor Behavior** - Watch HPA decisions and adjust thresholds
5. **Consider Pod Disruption Budgets** - Ensure availability during scale-down
6. **Test Under Load** - Validate HPA behavior before production deployment

## Troubleshooting

| Issue | Possible Cause | Solution |
|-------|----------------|----------|
| `<unknown>/70%` in TARGETS | Metrics server not running | Install metrics server |
| Not scaling up | Resource requests not set | Add requests to containers |
| Scaling too aggressively | Default behavior too fast | Add scaling policies |
| Not scaling down | Stabilization window | Wait for window to pass |
