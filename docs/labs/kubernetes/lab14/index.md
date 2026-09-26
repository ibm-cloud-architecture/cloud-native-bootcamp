---
tags:
  - Lab
  - Virtualization
  - OpenShift
  - Intermediate
---

# Lab 14 - Virtual Machines

<span class="lab-badge">45 min</span> <span class="lab-badge">Intermediate</span> <span class="lab-badge">OpenShift Virtualization</span>

## Problem

A legacy "hello" web service can't be containerized yet: it has to run on a full Fedora operating system. Run it as a **virtual machine** on OpenShift, next to your containers, and make it reachable the same way you would a containerized app.

See [OpenShift Virtualization](../../../openshift/virtualization/index.md) for the concepts.

## Prerequisites

- An OpenShift cluster with the **OpenShift Virtualization** operator installed, and worker nodes that support virtualization (bare metal, or cloud instances with virtualization enabled). See [Lab Environments](../../../lab-environments.md#virtualization).
- The `virtctl` CLI. In the web console, open the **?** menu > **Command Line Tools** and download **virtctl**, or on macOS run `brew install virtctl`.

```bash
oc new-project vm-lab
```

## Part 1: Create a VM

1. Save this VirtualMachine as `fedora-vm.yaml`. It sizes the VM with the `u1.small` **instance type** (1 vCPU, 2 GiB), applies the `fedora` **preference**, boots from a Fedora `containerDisk`, and uses **cloud-init** to create a user and start a small web server on port 8080:

    ```yaml title="fedora-vm.yaml"
    apiVersion: kubevirt.io/v1
    kind: VirtualMachine
    metadata:
      name: fedora-vm
    spec:
      runStrategy: Always
      instancetype:
        kind: VirtualMachineClusterInstancetype
        name: u1.small
      preference:
        kind: VirtualMachineClusterPreference
        name: fedora
      template:
        metadata:
          labels:
            app: fedora-vm        # Services select the VM by this label
        spec:
          domain:
            devices: {}
          volumes:
            - name: rootdisk
              containerDisk:
                image: quay.io/containerdisks/fedora:43
            - name: cloudinitdisk
              cloudInitNoCloud:
                userData: |
                  #cloud-config
                  user: fedora
                  password: bootcamp
                  chpasswd: { expire: false }
                  write_files:
                    - path: /srv/www/index.html
                      content: |
                        Hello from a virtual machine running on Kubernetes!
                    - path: /etc/systemd/system/hello-web.service
                      content: |
                        [Unit]
                        Description=Hello web server
                        After=network-online.target
                        [Service]
                        ExecStart=/usr/bin/python3 -m http.server 8080 --directory /srv/www
                        Restart=always
                        [Install]
                        WantedBy=multi-user.target
                  runcmd:
                    - systemctl daemon-reload
                    - systemctl enable --now hello-web.service
    ```

    !!! note "ARM clusters"
        On a cluster with ARM (aarch64) worker nodes, use the `fedora.arm64` preference.

2. Create the VM and watch it start. Which three objects represent it, and how are they related?

    ```bash
    oc apply -f fedora-vm.yaml
    oc get vm,vmi
    oc get pods -l app=fedora-vm -w
    ```

    Once the pod is `Running`, `oc get vmi` shows the VM's IP address and node. Also open **Virtualization > VirtualMachines** in the web console.

## Part 2: Log in

3. Open the VM's serial console and log in as `fedora` / `bootcamp`. It can take a minute or two after the pod starts before the login prompt appears. Check that the web server is running, then exit with ++ctrl+bracket-right++.

    ??? success "Solution"
        ```bash
        virtctl console fedora-vm
        ```

        Inside the VM:

        ```bash
        systemctl status hello-web --no-pager
        curl localhost:8080
        ```

        The web console's **Console** tab on the VM page gives you the same serial console, plus a graphical VNC console.

## Part 3: Lifecycle

4. Inside the VM, create a file: `echo "I was here" > ~/note.txt`. Then **restart** the VM with `virtctl`, log in again, and look for the file. What happened, and why?

    ??? success "Solution"
        ```bash
        virtctl restart fedora-vm
        oc get vmi -w          # the VMI is deleted and recreated
        virtctl console fedora-vm
        ls ~/note.txt          # No such file or directory
        ```

        The root disk is a **containerDisk**: an image pulled from a registry, like a container's filesystem. It's reset every time the VM starts. Real workloads use a persistent disk (a DataVolume backed by a PVC). See Part 5.

5. **Stop** the VM and look at what's left. Then start it again.

    ??? success "Solution"
        ```bash
        virtctl stop fedora-vm
        oc get vm,vmi,pods     # the VM remains (Stopped); the VMI and its pod are gone
        virtctl start fedora-vm
        ```

## Part 4: Networking

6. Create a Service named `fedora-vm` that exposes the VM's web server (port `8080`) on port `80`, then call it from a **container** in the same project.

    ??? success "Solution"
        ```yaml title="fedora-vm-service.yaml"
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

        ```bash
        oc apply -f fedora-vm-service.yaml
        oc run client --image=registry.access.redhat.com/ubi9/ubi-minimal -- sleep infinity
        oc wait --for=condition=Ready pod/client
        oc exec client -- curl -s fedora-vm
        ```

        `virtctl expose vm fedora-vm --name fedora-vm --port 80 --target-port 8080` creates the same Service.

7. Publish it outside the cluster with a Route, and open it in your browser.

    ??? success "Solution"
        ```bash
        oc expose service fedora-vm
        curl "http://$(oc get route fedora-vm -o jsonpath='{.spec.host}')"
        ```

        ```text
        Hello from a virtual machine running on Kubernetes!
        ```

        Containers and VMs use the same Services, Routes, DNS names and NetworkPolicies. A containerized frontend can call a VM backend by name, which is how teams modernize one piece at a time.

## Part 5 (optional): A VM with a persistent disk

8. Create a RHEL 9 VM whose disk is cloned from OpenShift's **golden image**, so changes survive restarts. Log in with SSH, restart the VM, and confirm a file you create is still there.

    ```bash
    virtctl create vm --name rhel9-vm \
      --instancetype u1.small --preference rhel.9 \
      --volume-import type:ds,src:openshift-virtualization-os-images/rhel9,size:30Gi \
      --user cloud-user --ssh-key "$(cat ~/.ssh/id_ed25519.pub)" | oc apply -f -

    oc get datavolume -w                  # the disk is cloned into a PVC
    virtctl ssh cloud-user@vm/rhel9-vm
    ```

    Replace `~/.ssh/id_ed25519.pub` with your public key. If you don't have one, create it with `ssh-keygen -t ed25519`.

## Cleanup

```bash
oc delete project vm-lab
```
