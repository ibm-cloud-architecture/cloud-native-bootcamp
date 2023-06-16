# Volumes

On-disk files in a Container are ephemeral, which presents some problems for non-trivial applications when running in Containers. First, when a Container crashes, kubelet will restart it, but the files will be lost - the Container starts with a clean state. Second, when running Containers together in a Pod it is often necessary to share files between those Containers. The Kubernetes Volume abstraction solves both of these problems.

Docker also has a concept of volumes, though it is somewhat looser and less managed. In Docker, a volume is simply a directory on disk or in another Container.

A Kubernetes volume, on the other hand, has an explicit lifetime - the same as the Pod that encloses it. Consequently, a volume outlives any Containers that run within the Pod, and data is preserved across Container restarts. Of course, when a Pod ceases to exist, the volume will cease to exist, too. Perhaps more importantly than this, Kubernetes supports many types of volumes, and a Pod can use any number of them simultaneously.


## Resources

**OpenShift**

- [Volume Lifecycle](https://docs.openshift.com/container-platform/4.13/storage/understanding-persistent-storage.html#lifecycle-volume-claim_understanding-persistent-storage){:target="_blank"}

**IKS**

- [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/){:target="_blank"}


## References


```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - image: busybox
    command: ['sh', '-c', 'echo Hello Kubernetes! && sleep 3600']
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
  - image: bitnami/nginx
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

# PersistentVolumes and PersistentVolumeClaims

Managing storage is a distinct problem from managing compute instances. The PersistentVolume subsystem provides an API for users and administrators that abstracts details of how storage is provided from how it is consumed.

A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes.

A PersistentVolumeClaim (PVC) is a request for storage by a user. It is similar to a Pod. Pods consume node resources and PVCs consume PV resources. Claims can request specific size and access modes (e.g., they can be mounted once read/write or many times read-only).

While PersistentVolumeClaims allow a user to consume abstract storage resources, it is common that users need PersistentVolumes with varying properties, such as performance, for different problems. Cluster administrators need to be able to offer a variety of PersistentVolumes that differ in more ways than just size and access modes, without exposing users to the details of how those volumes are implemented. For these needs, there is the StorageClass resource.

Pods access storage by using the claim as a volume. Claims must exist in the same namespace as the Pod using the claim. The cluster finds the claim in the Pod’s namespace and uses it to get the PersistentVolume backing the claim. The volume is then mounted to the host and into the Pod.

PersistentVolumes binds are exclusive, and since PersistentVolumeClaims are namespaced objects, mounting claims with “Many” modes (ROX, RWX) is only possible within one namespace.



## Resources
**OpenShift**

- [Persistent Storage](https://docs.openshift.com/container-platform/4.13/storage/understanding-persistent-storage.html){:target="_blank"}
- [Persistent Volume Types](https://docs.openshift.com/container-platform/4.13/storage/understanding-persistent-storage.html#types-of-persistent-volumes_understanding-persistent-storage){:target="_blank"}
- [Expanding Peristent Volumes](https://docs.openshift.com/container-platform/4.13/storage/expanding-persistent-volumes.html){:target="_blank"}

**IKS**

- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/){:target="_blank"}
- [Writing Portable Configurations](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#writing-portable-configuration){:target="_blank"}
- [Configuring Persistent Volume Storage](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/){:target="_blank"}

## References

```yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: my-pv
spec:
  storageClassName: local-storage
  capacity:
    storage: 128Mi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data-1"
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  storageClassName: local-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
```

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: my-pod
spec:
  containers:
  - name: nginx
    image: busybox
    command: ['sh', '-c', 'echo $(date):$HOSTNAME Hello Kubernetes! >> /mnt/data/message.txt && sleep 3600']
    volumeMounts:
    - mountPath: "/mnt/data"
      name: my-data
  volumes:
  - name: my-data
    persistentVolumeClaim:
      claimName: my-pvc
```

=== "OpenShift"

    ``` Bash title="Get the Persistent Volumes in Project"
    oc get pv
    ```

    ``` Bash title="Get the Persistent Volume Claims"
    oc get pvc
    ```

    ``` Bash title="Get a specific Persistent Volume"
    oc get pv <pv_claim>
    ```

=== "Kubernetes"

    ``` Bash title="Get the Persistent Volume"
    kubectl get pv
    ```

    ``` Bash title="Get the Persistent Volume Claims"
    kubectl get pvc
    ```

## Activities

| Task                            | Description         | Link        |
| --------------------------------| ------------------  |:----------- |
| *** Try It Yourself ***                         |         |    
| Setting up Persistent Volumes | Create a Persistent Volume that's accessible from a SQL Pod. | [Setting up Persistent Volumes](../labs/kube-overview/activities/labs/lab10/index.md) |

