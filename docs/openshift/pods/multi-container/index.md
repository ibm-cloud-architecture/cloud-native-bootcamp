# Multi-Containers Pod

Container images solve many real-world problems with existing packaging and deployment tools, but in addition to these significant benefits, containers offer us an opportunity to fundamentally re-think the way we build distributed applications. Just as service oriented architectures (SOA) encouraged the decomposition of applications into modular, focused services, containers should encourage the further decomposition of these services into closely cooperating modular containers. By virtue of establishing a boundary, containers enable users to build their services using modular, reusable components, and this in turn leads to services that are more reliable, more scalable and faster to build than applications built from monolithic containers.

## Resources

=== "Kubernetes"

    [Sidecar Logging :fontawesome-solid-bxoes-stacked:](https://kubernetes.io/docs/concepts/cluster-administration/logging/#using-a-sidecar-container-with-the-logging-agent){.md-button target="_blank"}

    [Shared Volume Communication :fontawesome-solid-boxes-stacked:](https://kubernetes.io/docs/tasks/access-application-cluster/communicate-containers-same-pod-shared-volume/){.md-button target="_blank"}

    [Toolkit Patterns :fontawesome-solid-boxes-stacked:](https://kubernetes.io/blog/2015/06/the-distributed-system-toolkit-patterns/){.md-button target="_blank"}

    [Brendan Burns Paper :fontawesome-solid-boxes-stacked:](https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/45406.pdf){.md-button target="_blank"}

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
| Multiple Containers   | Build a container using legacy container image. | [Multiple Containers](../../../labs/kubernetes/lab3/index.md) |
