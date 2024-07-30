# State Persistence

State persistence in the context of Kubernetes/OpenShift refers to the ability to maintain and retain the state or data of applications even when they are stopped, restarted, or moved between nodes.

This is achieved through the use of volumes, persistent volumes (PVs), and persistent volume claims (PVCs). **Volumes** provide a way to store and access data in a container, while **PVs** serve as the underlying storage resources provisioned by the cluster. **PVCs** act as requests made by applications for specific storage resources from the available PVs. By utilizing PVs and PVCs, applications can ensure that their state is preserved and accessible across pod restarts and migrations, enabling reliable and consistent data storage and retrieval throughout the cluster.

## Resources

[Volumes :fontawesome-solid-database:](https://kubernetes.io/docs/concepts/storage/volumes/){ .md-button target="\_blank"}

[Persistent Volumes :fontawesome-solid-database:](https://kubernetes.io/docs/concepts/storage/persistent-volumes/){ .md-button target="\_blank"}

[Persistent Volume Claims :fontawesome-solid-database:](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims){ .md-button target="\_blank"}

## References

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

In this example, we define a PVC named _my-pvc_ with the following specifications:

- _accessModes_ specify that the volume can be mounted as read-write by a single node at a time ("ReadWriteOnce")
- _resources.requests.storage_ specifies the requested storage size for the PVC ("1Gi")

## Activities

| Task                          | Description                                                  | Link                                                                  |
| ----------------------------- | ------------------------------------------------------------ | :-------------------------------------------------------------------- |
| **_Try It Yourself_**         |                                                              |
| Setting up Persistent Volumes | Create a Persistent Volume that's accessible from a SQL Pod. | [Setting up Persistent Volumes](../../labs/kubernetes/lab10/index.md) |
