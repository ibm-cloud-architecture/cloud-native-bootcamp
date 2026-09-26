---
tags:
  - Lab
  - Storage
  - Intermediate
---

# Lab 5 - Persistent Storage

<span class="lab-badge">30 min</span> <span class="lab-badge">Intermediate</span>

## Problem

The Death Star plans can't be lost no matter what happens, so we need to store them in a database whose data survives Pod restarts.

A container's filesystem is thrown away when its Pod is deleted. To keep data, the Pod needs a **PersistentVolumeClaim** (PVC). On OpenShift you normally don't create PersistentVolumes by hand. The cluster's default **StorageClass** provisions one automatically when a PVC asks for storage.

### Create a PersistentVolumeClaim

- The PVC is named `postgresql-pvc`.
- It requests `1Gi` of storage.
- It uses the access mode `ReadWriteOnce`.
- It doesn't set a `storageClassName`, so the cluster's default StorageClass is used.

### Create a PostgreSQL Pod that uses the claim

- The Pod is named `postgresql-pod` and has the label `app: postgresql`.
- It uses the image `quay.io/sclorg/postgresql-16-c9s`. This is the upstream build of Red Hat's PostgreSQL image, and it runs as any non-root user.
- It exposes `containerPort` `5432`.
- It sets these environment variables:

    | Name | Value |
    | --- | --- |
    | `POSTGRESQL_USER` | `rebel` |
    | `POSTGRESQL_PASSWORD` | `password` |
    | `POSTGRESQL_DATABASE` | `deathstar` |

- It mounts the PVC at `/var/lib/pgsql/data`.

## Setup

```bash
oc new-project lab5
oc get storageclass
```

One StorageClass should be marked `(default)`.

!!! note
    If the default StorageClass uses `WaitForFirstConsumer` binding mode, the PVC shows `Pending` until a Pod uses it. That's expected.

## Verification

1. The PVC is `Bound` and the Pod is `Running`:

    ```bash
    oc get pvc,pod
    ```

2. Save the plans to the database:

    ```bash
    oc exec postgresql-pod -- psql -d deathstar -c "CREATE TABLE plans (weakness text); INSERT INTO plans VALUES ('thermal exhaust port');"
    ```

3. Delete the Pod, then recreate it from the same manifest:

    ```bash
    oc delete pod postgresql-pod
    oc apply -f postgresql-pod.yaml
    oc wait --for=condition=Ready pod/postgresql-pod --timeout=120s
    ```

4. The plans survived:

    ```bash
    oc exec postgresql-pod -- psql -d deathstar -c "SELECT * FROM plans;"
    ```

    ```text
          weakness
    ----------------------
     thermal exhaust port
    (1 row)
    ```

## Going further

- Look at the PersistentVolume that was created for you with `oc get pv`. You may need cluster-reader access. What is its `RECLAIM POLICY`, and what happens to the data when you delete the PVC?
- A bare Pod is fine for learning, but real databases run as a StatefulSet with `volumeClaimTemplates`. See [StatefulSets](../../../openshift/deployments/statefulsets.md).

## Cleanup

```bash
oc delete project lab5
```
