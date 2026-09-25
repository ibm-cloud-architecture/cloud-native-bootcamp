# Volumes

On-disk files in a Container are ephemeral, which presents some problems for non-trivial applications when running in Containers. First, when a Container crashes, kubelet will restart it, but the files will be lost - the Container starts with a clean state. Second, when running Containers together in a Pod it is often necessary to share files between those Containers. The Kubernetes Volume abstraction solves both of these problems.

Docker also has a concept of volumes, though it is somewhat looser and less managed. In Docker, a volume is simply a directory on disk or in another Container.

A Kubernetes volume, on the other hand, has an explicit lifetime - the same as the Pod that encloses it. Consequently, a volume outlives any Containers that run within the Pod, and data is preserved across Container restarts. Of course, when a Pod ceases to exist, the volume will cease to exist, too. Perhaps more importantly than this, Kubernetes supports many types of volumes, and a Pod can use any number of them simultaneously.

## Resources

=== "OpenShift"

    [Volume Lifecycle :fontawesome-solid-database:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/storage/understanding-persistent-storage){ .md-button target="_blank"}

=== "Kubernetes"

    [Volumes :fontawesome-solid-database:](https://kubernetes.io/docs/concepts/storage/volumes/){ .md-button target="_blank"}

## References

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - image: busybox
      command: ["sh", "-c", "echo Hello Kubernetes! && sleep 3600"]
      name: busybox
      volumeMounts:
        - mountPath: /cache
          name: cache-volume
  volumes:
    - name: cache-volume
      emptyDir: {}
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
    - image: quay.io/nginx/nginx-unprivileged:1.29
      name: test-container
      volumeMounts:
        - mountPath: /test-pd
          name: test-volume
  volumes:
    - name: test-volume
      hostPath:
        # directory location on host
        path: /data
        # this field is optional
        type: Directory
```

!!! warning "hostPath is blocked by default"
    `hostPath` mounts a directory from the node into the pod, which gives the pod access to the host. OpenShift's default `restricted-v2` SCC and the Kubernetes `restricted` Pod Security level both reject it. It's meant for privileged node agents, such as log collectors or CSI drivers, that a cluster administrator has explicitly allowed. For application data, use a PersistentVolumeClaim.
