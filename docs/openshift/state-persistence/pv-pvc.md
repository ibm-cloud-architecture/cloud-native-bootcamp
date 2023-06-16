# PersistentVolumes and Claims

Managing storage is a distinct problem from managing compute instances. The PersistentVolume subsystem provides an API for users and administrators that abstracts details of how storage is provided from how it is consumed.

A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes.

A PersistentVolumeClaim (PVC) is a request for storage by a user. It is similar to a Pod. Pods consume node resources and PVCs consume PV resources. Claims can request specific size and access modes (e.g., they can be mounted once read/write or many times read-only).

While PersistentVolumeClaims allow a user to consume abstract storage resources, it is common that users need PersistentVolumes with varying properties, such as performance, for different problems. Cluster administrators need to be able to offer a variety of PersistentVolumes that differ in more ways than just size and access modes, without exposing users to the details of how those volumes are implemented. For these needs, there is the StorageClass resource.

Pods access storage by using the claim as a volume. Claims must exist in the same namespace as the Pod using the claim. The cluster finds the claim in the Pod’s namespace and uses it to get the PersistentVolume backing the claim. The volume is then mounted to the host and into the Pod.

PersistentVolumes binds are exclusive, and since PersistentVolumeClaims are namespaced objects, mounting claims with “Many” modes (ROX, RWX) is only possible within one namespace.



## Resources
**OpenShift**
- [Persistent Storage](https://docs.openshift.com/container-platform/4.3/storage/understanding-persistent-storage.html)
- [Persistent Volume Types](https://docs.openshift.com/container-platform/4.3/storage/understanding-persistent-storage.html#types-of-persistent-volumes_understanding-persistent-storage)
- [Expanding Peristent Volumes](https://docs.openshift.com/container-platform/4.3/storage/expanding-persistent-volumes.html)

**IKS**
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Writing Portable Configurations](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#writing-portable-configuration)
- [Configuring Persistent Volume Storage](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/)

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

<Tabs>

  <Tab label="OpenShift">

  **Getting the Persistent Volumes in Project** 
  ```
    oc get pv 
  ```
  **Getting the Persistent Volume Claims ** 
  ```
    oc get pvc
  ```
  **Getting a specific Persistent Volume** 
  ```
    oc get pv <pv-claim>
  ```

  </Tab>

  <Tab label="IKS">

  **Getting the PersistentVolume ** 
  ```
    kubectl get pv
  ```
  **Getting the PersistentVolumeClaims ** 
  ```
    kubectl get pvc
  ```

  </Tab>

</Tabs>