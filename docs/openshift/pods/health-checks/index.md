---
tags:
  - Pods
  - Observability
---

# Health and Monitoring

## Liveness and Readiness Probes

A probe is a diagnostic performed periodically by the kubelet on a container. Each probe uses one of four mechanisms:

**_exec_**: Runs a command inside the container. The check succeeds if the command exits with status code 0.

**_tcpSocket_**: Opens a TCP connection to the container's IP address on a specified port. The check succeeds if the port is open.

**_httpGet_**: Sends an HTTP GET request to the container's IP address on a specified port and path. The check succeeds if the response status code is at least 200 and below 400.

**_grpc_**: Calls the standard [gRPC health checking protocol](https://github.com/grpc/grpc/blob/master/doc/health-checking.md) on a specified port. The check succeeds if the service reports `SERVING`.

The kubelet can run three kinds of probes on each container:

**_startupProbe_**: Indicates whether the application inside the container has started. Liveness and readiness probes don't run until the startup probe succeeds. If it keeps failing, the container is restarted. Use it for slow-starting applications instead of a long `initialDelaySeconds`.

**_livenessProbe_**: Indicates whether the container is still working. Runs for the lifetime of the container. If it fails `failureThreshold` times in a row, the kubelet kills the container, and it's restarted according to the pod's `restartPolicy`.

**_readinessProbe_**: Indicates whether the container is ready to serve requests. It also runs for the lifetime of the container. While it fails, the pod is removed from the endpoints of every Service that selects it. The container is **not** restarted.

The timing of every probe is tuned with `initialDelaySeconds`, `periodSeconds` (default 10), `timeoutSeconds` (default 1), `failureThreshold` (default 3) and `successThreshold` (default 1).

### Resources

=== "OpenShift"

    <div class="grid cards" markdown>

      -   :fontawesome-solid-heart-pulse:{ .lg .middle } __Application Health__

          ---

          A health check periodically performs diagnostics on a running container using any combination of the readiness, liveness, and startup health checks.

          [:octicons-arrow-right-24: Learn more](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/building_applications/application-health){ target="_blank"}

      -   :fontawesome-solid-vr-cardboard:{ .lg .middle } __Virtual Machine Health__

          ---

          Use readiness and liveness probes to detect and handle unhealthy virtual machines (VMs).

          [:octicons-arrow-right-24: Learn more](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/virtualization/monitoring#virt-monitoring-vm-health){ target="_blank"}

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

```yaml title="Exec liveness probe"
apiVersion: v1
kind: Pod
metadata:
  name: exec-probe
spec:
  containers:
    - name: app
      image: busybox
      command: ["sh", "-c", "echo Hello, Kubernetes! && sleep 3600"]
      livenessProbe:
        exec:
          command: ["echo", "alive"]
```

```yaml title="TCP liveness and HTTP readiness probes"
apiVersion: v1
kind: Pod
metadata:
  name: web-probes
spec:
  containers:
    - name: app
      image: quay.io/nginx/nginx-unprivileged:1.29
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

```yaml title="Startup probe for a slow-starting app"
apiVersion: v1
kind: Pod
metadata:
  name: slow-start
spec:
  containers:
    - name: app
      image: quay.io/nginx/nginx-unprivileged:1.29
      ports:
        - containerPort: 8080
      startupProbe:          # allow up to 30 x 10s = 5 minutes to start
        httpGet:
          path: /
          port: 8080
        failureThreshold: 30
        periodSeconds: 10
      livenessProbe:         # only starts once the startup probe has passed
        httpGet:
          path: /
          port: 8080
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

          [:octicons-arrow-right-24: Learn more](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/cli_tools/openshift-cli-oc#cli-developer-commands){ target="_blank"}

      -   :fontawesome-solid-circle-nodes:{ .lg .middle } __Cluster Logging__

          ---

          As a cluster administrator, you can deploy logging on an OpenShift Container Platform cluster, and use it to collect and aggregate node system audit logs, application container logs, and infrastructure logs.

          [:octicons-arrow-right-24: Learn more](https://docs.redhat.com/en/documentation/red_hat_openshift_logging/){ target="_blank"}

      -   :fontawesome-solid-file-lines:{ .lg .middle } __Logging Collector__

          ---

          The collector collects log data from each node, transforms the data, and forwards it to configured outputs.

          [:octicons-arrow-right-24: Learn more](https://docs.redhat.com/en/documentation/red_hat_openshift_logging/){ target="_blank"}

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
    oc logs counter                  # current logs
    oc logs -f counter               # follow new lines
    oc logs counter --previous       # logs from the previous (crashed) container
    oc logs counter -c count         # a specific container in a multi-container pod
    oc logs deployment/my-deployment # logs from a pod of a deployment
    ```

    ``` Bash title="Use Stern to View Logs"
    brew install stern
    stern . -n default
    ```

=== "Kubernetes"

    ``` Bash title="Get Logs"
    kubectl logs counter
    kubectl logs -f counter
    kubectl logs counter --previous
    kubectl logs counter -c count
    kubectl logs deployment/my-deployment
    ```

    ``` Bash title="Use Stern to View Logs"
    brew install stern
    stern . -n default
    ```

## Monitoring Applications

To scale an application and provide a reliable service, you need to understand how the application behaves when it is deployed. You can examine application performance in a Kubernetes cluster by examining the containers, pods, services, and the characteristics of the overall cluster. Kubernetes provides detailed information about an application’s resource usage at each of these levels. This information allows you to evaluate your application’s performance and where bottlenecks can be removed to improve overall performance.

[Prometheus](https://prometheus.io/), a CNCF project, can natively monitor Kubernetes, nodes, and Prometheus itself. OpenShift includes a preconfigured Prometheus-based monitoring stack, and can also monitor your own applications' metrics (user workload monitoring).

### Resources

=== "OpenShift"

    <div class="grid cards" markdown>

      -   :fontawesome-solid-binoculars:{ .lg .middle } __Monitoring Application Health__

          ---

          OpenShift Container Platform applications have a number of options to detect and handle unhealthy containers.

          [:octicons-arrow-right-24: Learn more](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/building_applications/application-health){ target="_blank"}

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

The following pods use the Kubernetes `resource-consumer` test image to burn a fixed amount of CPU, so you can watch resource usage:

```yaml title="cpu-500m.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: cpu-500m
spec:
  containers:
    - name: app
      image: registry.k8s.io/e2e-test-images/resource-consumer:1.13
      resources:
        requests:
          cpu: 700m
          memory: 128Mi
    - name: load-generator
      image: registry.access.redhat.com/ubi9/ubi-minimal
      command:
        - /bin/sh
        - -c
        - until curl -s localhost:8080/ConsumeCPU -d "millicores=500&durationSec=3600"; do sleep 5; done && sleep infinity
```

```yaml title="cpu-200m.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: cpu-200m
spec:
  containers:
    - name: app
      image: registry.k8s.io/e2e-test-images/resource-consumer:1.13
      resources:
        requests:
          cpu: 300m
          memory: 64Mi
    - name: load-generator
      image: registry.access.redhat.com/ubi9/ubi-minimal
      command:
        - /bin/sh
        - -c
        - until curl -s localhost:8080/ConsumeCPU -d "millicores=200&durationSec=3600"; do sleep 5; done && sleep infinity
```

=== "OpenShift"

    OpenShift ships with cluster monitoring (Prometheus) and the metrics API enabled. You can also see pod metrics in the web console under **Observe** in the developer perspective.

    ``` Bash title="Resource usage of pods and nodes"
    oc adm top pods
    oc adm top pods --containers
    oc adm top nodes
    ```

    ``` Bash title="Explore the cluster"
    oc get projects
    oc api-resources -o wide
    oc get nodes,ns,po,deploy,svc
    oc describe node <node-name>
    ```

=== "Kubernetes"

    Resource metrics require the [metrics-server](https://github.com/kubernetes-sigs/metrics-server), which most managed Kubernetes services install for you.

    ``` Bash title="Verify metrics are enabled"
    kubectl get --raw /apis/metrics.k8s.io/
    ```

    ``` Bash title="Check resource usage"
    kubectl top pods
    kubectl top pods --containers
    kubectl top nodes
    ```

    ``` Bash title="Get node description"
    kubectl describe node <node-name>
    ```

## Activities

| Lab | Description |
| --- | ----------- |
| [Lab 2 - Probes](../../../labs/kubernetes/lab2/index.md) | Add liveness and readiness probes to recover from an unhealthy app |
