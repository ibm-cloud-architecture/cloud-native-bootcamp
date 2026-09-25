---
tags:
  - Solution
  - Storage
---

# Lab 5 Solution - Persistent Storage

```yaml title="postgresql-pvc.yaml"
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgresql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

```yaml title="postgresql-pod.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: postgresql-pod
  labels:
    app: postgresql
spec:
  containers:
    - name: postgresql
      image: quay.io/sclorg/postgresql-16-c9s
      ports:
        - containerPort: 5432
      env:
        - name: POSTGRESQL_USER
          value: rebel
        - name: POSTGRESQL_PASSWORD
          value: password
        - name: POSTGRESQL_DATABASE
          value: deathstar
      volumeMounts:
        - name: data
          mountPath: /var/lib/pgsql/data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: postgresql-pvc
```

```bash
oc apply -f postgresql-pvc.yaml
oc apply -f postgresql-pod.yaml
oc get pvc,pod
```

```text title="Expected output"
NAME                                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/postgresql-pvc   Bound    pvc-3f6c1c2e-8a0e-4c8e-9a52-6f0d7f2b1c11   1Gi        RWO            gp3-csi        40s

NAME                 READY   STATUS    RESTARTS   AGE
pod/postgresql-pod   1/1     Running   0          40s
```

The `STORAGECLASS` column depends on your cluster: for example `gp3-csi` on AWS, `crc-csi-hostpath-provisioner` on OpenShift Local, or `standard` on kind.

Then follow the verification steps in the lab to write data, delete the Pod, and read the data back.

!!! info "Static provisioning"
    Before dynamic provisioning, a cluster administrator created PersistentVolumes by hand, for example with `hostPath` or NFS, and PVCs bound to them by matching `storageClassName`, access mode and size. You'll still see this on bare-metal clusters. It requires cluster-admin rights, and `hostPath` volumes are blocked by OpenShift's default security context constraints. See [Persistent Volumes & Claims](../../../openshift/state-persistence/pv-pvc.md).
