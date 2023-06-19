# Liveness and Readiness Probes

A Probe is a diagnostic performed periodically by the kubelet on a Container. To perform a diagnostic, the kubelet calls a Handler implemented by the Container. There are three types of handlers:

***ExecAction***: Executes a specified command inside the Container. The diagnostic is considered successful if the command exits with a status code of 0.

***TCPSocketAction***: Performs a TCP check against the Container’s IP address on a specified port. The diagnostic is considered successful if the port is open.

***HTTPGetAction***: Performs an HTTP Get request against the Container’s IP address on a specified port and path. The diagnostic is considered successful if the response has a status code greater than or equal to 200 and less than 400.

The kubelet can optionally perform and react to three kinds of probes on running Containers:

***livenessProbe***: Indicates whether the Container is running. Runs for the lifetime of the Container.

***readinessProbe***: Indicates whether the Container is ready to service requests. Only runs at start.

### Resources

=== "OpenShift"
    [Application Health :fontawesome-solid-globe:](https://docs.openshift.com/container-platform/4.12/applications/application-health.html){ .md-button }
    [Virtual Machine Health :fontawesome-solid-globe:](https://docs.openshift.com/container-platform/4.12/virt/logging_events_monitoring/virt-monitoring-vm-health.html){ .md-button }

=== "Kubernetes"
    - [Container Probes](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes)
    - [Configure Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)

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
    command: ['sh', '-c', "echo Hello, Kubernetes! && sleep 3600"]
    livenessProbe:
      exec:
        command: ['echo','alive']
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

**OpenShift**

- [Logs Command](https://docs.openshift.com/container-platform/4.13/cli_reference/openshift_cli/developer-cli-commands.html){:target="_blank"}
- [Cluster Logging](https://docs.openshift.com/container-platform/4.13/logging/cluster-logging.html){:target="_blank"}
- [Logging Collector](https://docs.openshift.com/container-platform/4.13/logging/config/cluster-logging-collector.html){:target="_blank"}

**IKS**

- [Logging](https://kubernetes.io/docs/concepts/cluster-administration/logging/){:target="_blank"}

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
    command: ['sh','-c','i=0; while true; do echo "$i: $(date)"; i=$((i+1)); sleep 5; done']
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

**OpenShift**

- [Monitoring Application Health](https://docs.openshift.com/container-platform/4.13/applications/application-health.html){:target="_blank"}

**IKS**

- [Monitoring Resource Usage](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/){:target="_blank"}
- [Resource Metrics](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-metrics-pipeline/){:target="_blank"}

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
    command: [/bin/sh, -c, 'until curl localhost:8080/ConsumeCPU -d "millicores=500&durationSec=3600"; do sleep 5; done && sleep 3700']
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
    command: [/bin/sh, -c, 'until curl localhost:8080/ConsumeCPU -d "millicores=200&durationSec=3600"; do sleep 5; done && sleep 3700']
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
    ** Verify Metrics is enabled**
    ```
    kubectl get --raw /apis/metrics.k8s.io/
    ```

    ** Get Node Description **
    ```
    kubectl describe node
    ```

    ** Check Resource Useage **
    ```
    kubectl top pods
    kubectl top nodes
    ```

</Tab>

</Tabs>

## Activities

| Task                            | Description         | Link        |
| --------------------------------| ------------------  |:----------- |
| *** Try It Yourself ***                         |         |         |
| Probes | Create some Health & Startup Probes to find what's causing an issue.  | [Probes](../../../labs/kubernetes/lab4/index.md) |
