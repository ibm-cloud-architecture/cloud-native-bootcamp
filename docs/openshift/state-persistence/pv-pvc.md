# PersistentVolumes and Claims

Managing storage is a distinct problem from managing compute instances. The PersistentVolume subsystem provides an API for users and administrators that abstracts details of how storage is provided from how it is consumed.

A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes.

A PersistentVolumeClaim (PVC) is a request for storage by a user. It is similar to a Pod. Pods consume node resources and PVCs consume PV resources. Claims can request specific size and access modes (e.g., they can be mounted once read/write or many times read-only).

While PersistentVolumeClaims allow a user to consume abstract storage resources, it is common that users need PersistentVolumes with varying properties, such as performance, for different problems. Cluster administrators need to be able to offer a variety of PersistentVolumes that differ in more ways than just size and access modes, without exposing users to the details of how those volumes are implemented. For these needs, there is the StorageClass resource.

Pods access storage by using the claim as a volume. Claims must exist in the same namespace as the Pod using the claim. The cluster finds the claim in the Pod’s namespace and uses it to get the PersistentVolume backing the claim. The volume is then mounted to the host and into the Pod.

PersistentVolumes binds are exclusive, and since PersistentVolumeClaims are namespaced objects, mounting claims with “Many” modes (ROX, RWX) is only possible within one namespace.

## Resources

=== "OpenShift"

    [Persistent Storage :fontawesome-solid-database:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/storage/understanding-persistent-storage){ .md-button target="_blank"}

    [Persistent Volume Types :fontawesome-solid-database:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/storage/understanding-persistent-storage){ .md-button target="_blank"}

    [Expanding Peristent Volumes :fontawesome-solid-database:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/storage/expanding-persistent-volumes){ .md-button target="_blank"}

=== "Kubernetes"

    [Persistent Volumes :fontawesome-solid-database:](https://kubernetes.io/docs/concepts/storage/persistent-volumes/){ .md-button target="_blank"}

    [Writing Portable Configurations :fontawesome-solid-database:](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#writing-portable-configuration){ .md-button target="_blank"}

    [Configuring Persistent Volume Storage :fontawesome-solid-database:](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/){ .md-button target="_blank"}

## References

### Dynamic provisioning (the usual way)

Create a claim without a `storageClassName`, and the cluster's default StorageClass provisions a matching PersistentVolume for you. This is how storage works on OpenShift and managed Kubernetes services, and it doesn't need any special permissions.

```yaml title="PersistentVolumeClaim"
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
```

```yaml title="Pod using the claim"
kind: Pod
apiVersion: v1
metadata:
  name: my-pod
spec:
  containers:
    - name: app
      image: busybox
      command:
        [
          "sh",
          "-c",
          "echo $(date):$HOSTNAME Hello Kubernetes! >> /mnt/data/message.txt && sleep 3600",
        ]
      volumeMounts:
        - mountPath: "/mnt/data"
          name: my-data
  volumes:
    - name: my-data
      persistentVolumeClaim:
        claimName: my-pvc
```

Delete and recreate the pod, then run `oc exec my-pod -- cat /mnt/data/message.txt`. It shows one line per pod that has run, because the data lives in the PersistentVolume, not in the container.

### Static provisioning (cluster administrators)

Without a provisioner, an administrator creates PersistentVolumes by hand, and claims bind to them by matching `storageClassName`, access mode and size. `hostPath` volumes like this one are only suitable for single-node test clusters. On OpenShift, pods running under the default `restricted-v2` SCC generally can't write to a root-owned host directory, so you would use NFS, iSCSI or a CSI driver instead.

```yaml title="PersistentVolume (requires cluster-admin)"
kind: PersistentVolume
apiVersion: v1
metadata:
  name: my-pv
spec:
  storageClassName: manual
  capacity:
    storage: 128Mi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "/mnt/data-1"
```

```yaml title="PersistentVolumeClaim that binds to it"
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-static-pvc
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
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

| Lab | Description |
| --- | ----------- |
| [Lab 5 - Persistent Storage](../../labs/kubernetes/lab5/index.md) | Give a PostgreSQL pod storage that survives restarts |
