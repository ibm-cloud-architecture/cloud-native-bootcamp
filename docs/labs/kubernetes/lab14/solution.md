---
tags:
  - Solution
  - Virtualization
---

# Lab 14 Solution - Virtual Machines

The solutions for each step are inline in the lab, in the collapsible **Solution** blocks. This page answers the questions.

## Step 2: How a VM is represented

```bash
oc get vm,vmi,pods
```

```text
NAME                                   AGE   STATUS    READY
virtualmachine.kubevirt.io/fedora-vm   2m    Running   True

NAME                                           AGE   PHASE     IP            NODENAME   READY
virtualmachineinstance.kubevirt.io/fedora-vm   2m    Running   10.131.0.42   worker-1   True

NAME                                READY   STATUS    RESTARTS   AGE
pod/virt-launcher-fedora-vm-7xk2p   2/2     Running   0          2m
```

- The **VirtualMachine** is the definition you created. It persists while the VM is stopped.
- The **VirtualMachineInstance** is the running VM, created by the VM because `runStrategy: Always`.
- The **virt-launcher pod** runs the QEMU/KVM process on a node. It carries the VM template's labels (`app: fedora-vm`), which is why a normal Service can select it.

## Step 4: The disappearing file

The root disk is a `containerDisk`, which is ephemeral: each start begins from the original image, just like a container's filesystem. Use DataVolumes (Part 5) for anything that must persist.

## Step 5: Stop

| After `virtctl stop` | Present? |
| --- | --- |
| VirtualMachine | Yes, status `Stopped`, `runStrategy: Halted` |
| VirtualMachineInstance | No |
| virt-launcher pod | No |

`virtctl stop` and `virtctl start` change the VM's `runStrategy` between `Halted` and `Always`. You could make the same change in YAML, and in a GitOps setup you would.

## Step 6: Service for the VM

```yaml
apiVersion: v1
kind: Service
metadata:
  name: fedora-vm
spec:
  selector:
    app: fedora-vm
  ports:
    - port: 80
      targetPort: 8080
```

The VM's network interface uses **masquerade** binding on the pod network, so traffic to the pod IP on port 8080 is forwarded to the guest OS.
