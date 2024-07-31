# Health and Monitoring

## Liveness and Readiness Probes

A Probe is a diagnostic performed periodically by the kubelet on a Container. To perform a diagnostic, the kubelet calls a Handler implemented by the Container. There are three types of handlers:

**_ExecAction_**: Executes a specified command inside the Container. The diagnostic is considered successful if the command exits with a status code of 0.

**_TCPSocketAction_**: Performs a TCP check against the Container’s IP address on a specified port. The diagnostic is considered successful if the port is open.

**_HTTPGetAction_**: Performs an HTTP Get request against the Container’s IP address on a specified port and path. The diagnostic is considered successful if the response has a status code greater than or equal to 200 and less than 400.

The kubelet can optionally perform and react to three kinds of probes on running Containers:

**_livenessProbe_**: Indicates whether the Container is running. Runs for the lifetime of the Container.

**_readinessProbe_**: Indicates whether the Container is ready to service requests. Only runs at start.

### Resources

=== "OpenShift"

    <div class="grid cards" markdown>

      -   :fontawesome-solid-heart-pulse:{ .lg .middle } __Application Health__

          ---

          A health check periodically performs diagnostics on a running container using any combination of the readiness, liveness, and startup health checks.

          [:octicons-arrow-right-24: Learn more](https://docs.openshift.com/container-platform/4.14/applications/application-health.html){ target="_blank"}

      -   :fontawesome-solid-vr-cardboard:{ .lg .middle } __Virtual Machine Health__

          ---

          Use readiness and liveness probes to detect and handle unhealthy virtual machines (VMs).

          [:octicons-arrow-right-24: Learn more](https://docs.openshift.com/container-platform/4.14/virt/monitoring/virt-monitoring-vm-health.html){ target="_blank"}

    </div>

=== "Kubernetes"

    <div class="grid cards" markdown>

      -   :fontawesome-solid-stethoscope:{ .lg .middle } __Container Probes__

          ---

          To perform a diagnostic, the kubelet either executes code within the container, or makes a network request.

          [:octicons-arrow-right-24: Learn more](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes){ target="_blank"}

      -   :fontawesome-solid-pen-to-square:{ .lg .middle } __Configure Probes__

          ---

          Read about how to configure liveness, readiness and startup probes for containers.

          [:octicons-arrow-right-24: Learn more](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/){ target="_blank"}

    </div>

### References

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: app
      image: busybox
      command: ["sh", "-c", "echo Hello, Kubernetes! && sleep 3600"]
      livenessProbe:
        exec:
          command: ["echo", "alive"]
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  shareProcessNamespace: true
  containers:
    - name: app
      image: bitnami/nginx
      ports:
        - containerPort: 8080
      livenessProbe:
        tcpSocket:
          port: 8080
        initialDelaySeconds: 10
      readinessProbe:
        httpGet:
          path: /
          port: 8080
        periodSeconds: 10
```

## Container Logging

Application and systems logs can help you understand what is happening inside your cluster. The logs are particularly useful for debugging problems and monitoring cluster activity.

Kubernetes provides no native storage solution for log data, but you can integrate many existing logging solutions into your Kubernetes cluster.

### Resources

=== "OpenShift"

    <div class="grid cards" markdown>

      -   :fontawesome-solid-terminal:{ .lg .middle } __Logs Command__

          ---

          Read about the descriptions and example commands for OpenShift CLI (`oc`) developer commands.

          [:octicons-arrow-right-24: Learn more](https://docs.openshift.com/container-platform/4.13/cli_reference/openshift_cli/developer-cli-commands.html){ target="_blank"}

      -   :fontawesome-solid-circle-nodes:{ .lg .middle } __Cluster Logging__

          ---

          As a cluster administrator, you can deploy logging on an OpenShift Container Platform cluster, and use it to collect and aggregate node system audit logs, application container logs, and infrastructure logs.

          [:octicons-arrow-right-24: Learn more](https://docs.openshift.com/container-platform/4.13/logging/cluster-logging.html){ target="_blank"}

      -   :fontawesome-solid-file-lines:{ .lg .middle } __Logging Collector__

          ---

          The collector collects log data from each node, transforms the data, and forwards it to configured outputs.

          [:octicons-arrow-right-24: Learn more](https://docs.openshift.com/container-platform/4.13/observability/logging/cluster-logging.html#logging-architecture-overview_cluster-logging){ target="_blank"}

    </div>

=== "Kubernetes"

    <div class="grid cards" markdown>

      -   :fontawesome-solid-file-lines:{ .lg .middle } __Logging__

          ---

          Application logs can help you understand what is happening inside your application and are particularly useful for debugging problems and monitoring cluster activity.

          [:octicons-arrow-right-24: Getting started](https://kubernetes.io/docs/concepts/cluster-administration/logging/){ target="_blank"}

    </div>

### References

```yaml title="Pod Example"
apiVersion: v1
kind: Pod
metadata:
  name: counter
spec:
  containers:
    - name: count
      image: busybox
      command:
        [
          "sh",
          "-c",
          'i=0; while true; do echo "$i: $(date)"; i=$((i+1)); sleep 5; done',
        ]
```

=== "OpenShift"

    ```Bash title="Get Logs"
    oc logs
    ```

    ``` Bash title="Use Stern to View Logs"
    brew install stern
    stern . -n default
    ```

=== "Kubernetes"

    ``` Bash title="Get Logs"
    kubectl logs
    ```

    ``` Bash title="Use Stern to View Logs"
    brew install stern
    stern . -n default
    ```

## Monitoring Applications

To scale an application and provide a reliable service, you need to understand how the application behaves when it is deployed. You can examine application performance in a Kubernetes cluster by examining the containers, pods, services, and the characteristics of the overall cluster. Kubernetes provides detailed information about an application’s resource usage at each of these levels. This information allows you to evaluate your application’s performance and where bottlenecks can be removed to improve overall performance.

Prometheus, a CNCF project, can natively monitor Kubernetes, nodes, and Prometheus itself.

### Resources

=== "OpenShift"

    <div class="grid cards" markdown>

      -   :fontawesome-solid-binoculars:{ .lg .middle } __Monitoring Application Health__

          ---

          OpenShift Container Platform applications have a number of options to detect and handle unhealthy containers.

          [:octicons-arrow-right-24: Learn more](https://docs.openshift.com/container-platform/4.13/applications/application-health.html){ target="_blank"}

    </div>

=== "Kubernetes"

    <div class="grid cards" markdown>

      -   :fontawesome-solid-magnifying-glass:{ .lg .middle } __Monitoring Resource Usage__

          ---

          You can examine application performance in a Kubernetes cluster by examining the containers, pods, services, and the characteristics of the overall cluster.

          [:octicons-arrow-right-24: Learn more](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/){ target="_blank"}

      -   :fontawesome-brands-sourcetree:{ .lg .middle } __Resource Metrics__

          ---

          For Kubernetes, the Metrics API offers a basic set of metrics to support automatic scaling and similar use cases.

          [:octicons-arrow-right-24: Learn more](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-metrics-pipeline/){ target="_blank"}

    </div>

### References

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: 500m
spec:
  containers:
    - name: app
      image: gcr.io/kubernetes-e2e-test-images/resource-consumer:1.4
      resources:
        requests:
          cpu: 700m
          memory: 128Mi
    - name: busybox-sidecar
      image: radial/busyboxplus:curl
      command:
        [
          /bin/sh,
          -c,
          'until curl localhost:8080/ConsumeCPU -d "millicores=500&durationSec=3600"; do sleep 5; done && sleep 3700',
        ]
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: 200m
spec:
  containers:
    - name: app
      image: gcr.io/kubernetes-e2e-test-images/resource-consumer:1.4
      resources:
        requests:
          cpu: 300m
          memory: 64Mi
    - name: busybox-sidecar
      image: radial/busyboxplus:curl
      command:
        [
          /bin/sh,
          -c,
          'until curl localhost:8080/ConsumeCPU -d "millicores=200&durationSec=3600"; do sleep 5; done && sleep 3700',
        ]
```

=== "OpenShift"

    ```
    oc get projects
    oc api-resources -o wide
    oc api-resources -o name

    oc get nodes,ns,po,deploy,svc

    oc describe node --all
    ```

=== "Kubernetes"

    **Verify Metrics is enabled**
    ```
    kubectl get --raw /apis/metrics.k8s.io/
    ```

    **Get Node Description**
    ```
    kubectl describe node
    ```

    **Check Resource Usage**
    ```
    kubectl top pods
    kubectl top nodes
    ```

</Tab>

</Tabs>

## Activities

| Task                  | Description                                                          | Link                                             |
| --------------------- | -------------------------------------------------------------------- | :----------------------------------------------- |
| **_Try It Yourself_** |                                                                      |                                                  |
| Probes                | Create some Health & Startup Probes to find what's causing an issue. | [Probes](../../../labs/kubernetes/lab4/index.md) |
