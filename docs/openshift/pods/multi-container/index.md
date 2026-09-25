# Multi-Containers Pod

Container images solve many real-world problems with existing packaging and deployment tools, but in addition to these significant benefits, containers offer us an opportunity to fundamentally re-think the way we build distributed applications. Just as service oriented architectures (SOA) encouraged the decomposition of applications into modular, focused services, containers should encourage the further decomposition of these services into closely cooperating modular containers. By virtue of establishing a boundary, containers enable users to build their services using modular, reusable components, and this in turn leads to services that are more reliable, more scalable and faster to build than applications built from monolithic containers.

## Resources

=== "Kubernetes"

    <div class="grid cards" markdown>

      -   :fontawesome-solid-file-lines:{ .lg .middle } __Sidecar Logging__

          ---

          Application logs can help you understand what is happening inside your application.

          [:octicons-arrow-right-24: Learn more](https://kubernetes.io/docs/concepts/cluster-administration/logging/#using-a-sidecar-container-with-the-logging-agent){ target="_blank"}

      -   :fontawesome-solid-circle-nodes:{ .lg .middle } __Shared Volume Communication__

          ---

          Read about how to use a Volume to communicate between two Containers running in the same Pod.

          [:octicons-arrow-right-24: Learn more](https://kubernetes.io/docs/tasks/access-application-cluster/communicate-containers-same-pod-shared-volume/){ target="_blank"}

      -   :fontawesome-solid-blog:{ .lg .middle } __Toolkit Patterns__

          ---

          Read Brendan Burns' blog post about "The Distributed System ToolKit: Patterns for Composite Containers".

          [:octicons-arrow-right-24: Learn more](https://kubernetes.io/blog/2015/06/the-distributed-system-toolkit-patterns/){ target="_blank"}

      -   :fontawesome-solid-user:{ .lg .middle } __Brendan Burns Paper__

          ---

          Read Brendan Burns' paper about design patterns for container-based distributed systems.

          [:octicons-arrow-right-24: Learn more](https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/45406.pdf){ target="_blank"}

    </div>

## References

### Sharing files through a volume

Containers in a Pod can share volumes. Here a helper container writes the web page that nginx serves:

```yaml title="shared-volume.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: shared-volume
spec:
  volumes:
    - name: shared-data
      emptyDir: {}
  containers:
    - name: app
      image: quay.io/nginx/nginx-unprivileged:1.29
      volumeMounts:
        - name: shared-data
          mountPath: /usr/share/nginx/html
      ports:
        - containerPort: 8080
    - name: content
      image: busybox
      volumeMounts:
        - name: shared-data
          mountPath: /pod-data
      command:
        - sh
        - -c
        - echo "Hello from the side container" > /pod-data/index.html && sleep infinity
```

Containers in a Pod also share the network namespace, so the helper can reach nginx on `localhost`:

=== "OpenShift"

    ```bash
    oc apply -f shared-volume.yaml
    oc exec shared-volume -c content -- wget -qO- localhost:8080
    ```

=== "Kubernetes"

    ```bash
    kubectl apply -f shared-volume.yaml
    kubectl exec shared-volume -c content -- wget -qO- localhost:8080
    ```

```text title="Expected output"
Hello from the side container
```

### Native sidecar containers

A **sidecar** is a helper that runs alongside the app for the Pod's whole life, such as a log shipper, proxy or config reloader. Since Kubernetes 1.29 (OpenShift 4.16), you declare a sidecar as an `initContainer` with `restartPolicy: Always`. It starts **before** the app containers, keeps running next to them, and stops **after** them. That matters for Jobs, too: a regular second container would keep a Job's Pod from ever completing, while a native sidecar is stopped automatically when the main container finishes.

```yaml title="native-sidecar.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: native-sidecar
spec:
  volumes:
    - name: logs
      emptyDir: {}
  initContainers:
    - name: log-shipper
      image: busybox
      restartPolicy: Always       # this makes it a sidecar
      command: ["sh", "-c", "touch /var/log/app/app.log && tail -F /var/log/app/app.log"]
      volumeMounts:
        - name: logs
          mountPath: /var/log/app
  containers:
    - name: app
      image: busybox
      command: ["sh", "-c", "for i in 1 2 3 4 5; do echo \"event $i\" >> /var/log/app/app.log; sleep 2; done"]
      volumeMounts:
        - name: logs
          mountPath: /var/log/app
  restartPolicy: Never
```

After about 10 seconds the app container finishes, the sidecar is stopped, and the Pod reaches `Completed`. The sidecar's logs contain the app's events:

```bash
oc logs native-sidecar -c log-shipper
```

### Sharing the process namespace

With `shareProcessNamespace: true`, containers in a Pod can see each other's processes. For example, a helper can signal nginx to reload its configuration:

```yaml title="shared-processes.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: shared-processes
spec:
  shareProcessNamespace: true
  containers:
    - name: app
      image: quay.io/nginx/nginx-unprivileged:1.29
      ports:
        - containerPort: 8080
    - name: helper
      image: busybox
      command: ["sleep", "infinity"]
```

=== "OpenShift"

    ```bash
    oc apply -f shared-processes.yaml
    oc exec shared-processes -c helper -- ps
    oc exec shared-processes -c helper -- pkill -HUP -o nginx
    oc logs shared-processes -c app | grep -i sighup
    ```

=== "Kubernetes"

    ```bash
    kubectl apply -f shared-processes.yaml
    kubectl exec shared-processes -c helper -- ps
    kubectl exec shared-processes -c helper -- pkill -HUP -o nginx
    kubectl logs shared-processes -c app | grep -i sighup
    ```

`ps` lists the nginx processes from the `app` container. After the `HUP` signal, the nginx log shows `signal 1 (SIGHUP) received from ..., reconfiguring`.

!!! note
    Signalling another container's process requires both containers to run as the same user. On OpenShift that's always the case, because every container in the Pod gets the same UID. Adding capabilities such as `SYS_PTRACE` isn't allowed under the default `restricted-v2` SCC.

## Activities

| Lab | Description |
| --- | ----------- |
| [Lab 4 - Multi-Container Pods](../../../labs/kubernetes/lab4/index.md) | Use the ambassador pattern to expose a legacy app |
