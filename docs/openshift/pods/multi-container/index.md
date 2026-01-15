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

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  volumes:
    - name: shared-data
      emptyDir: {}
  containers:
    - name: app
      image: bitnami/nginx
      volumeMounts:
        - name: shared-data
          mountPath: /app
      ports:
        - containerPort: 8080
    - name: sidecard
      image: busybox
      volumeMounts:
        - name: shared-data
          mountPath: /pod-data
      command:
        [
          "sh",
          "-c",
          "echo Hello from the side container > /pod-data/index.html && sleep 3600",
        ]
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
    - name: sidecard
      image: busybox
      securityContext:
        capabilities:
          add:
            - SYS_PTRACE
      stdin: true
      tty: true
```

=== "OpenShift"

    **Attach Pods Together**
    ```
    oc attach -it my-pod -c sidecard
    ```
    ```
    ps ax
    ```
    ```
    kill -HUP 7
    ```
    ```
    ps ax
    ```

=== "Kubernetes"

    **Attach Pods Together**
    ```
    kubectl attach -it my-pod -c sidecard
    ```
    ```
    ps ax
    ```
    ```
    kill -HUP 7
    ```
    ```
    ps ax
    ```

## Activities

| Task                  | Description                                     | Link                                                          |
| --------------------- | ----------------------------------------------- | :------------------------------------------------------------ |
| **_Try It Yourself_** |                                                 |                                                               |
| Multiple Containers   | Build a container using legacy container image. | [Multiple Containers](../../../labs/kubernetes/lab4/index.md) |
