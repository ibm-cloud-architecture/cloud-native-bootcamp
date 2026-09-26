---
tags:
  - Getting started
---

# Lab Environments

The labs need different things. The container labs need only Podman on your laptop. Most Kubernetes labs run on any cluster. The DevOps, observability and virtualization labs need OpenShift features. This page shows which environment works for each lab and how to get it.

## Which environment for which lab

| Labs | Podman only | Local cluster (kind) | OpenShift Local | Developer Sandbox | Full OpenShift cluster |
| --- | :---: | :---: | :---: | :---: | :---: |
| [Containers Lab](labs/containers/index.md) | :white_check_mark: | | | | |
| [Image Registry Lab](labs/containers/container-registry/index.md) | Parts 1–2 | Parts 1–2 | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| [Kubernetes Labs 1–10](labs/kubernetes/index.md) | | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| [Lab 11 - Routes & Ingress](labs/kubernetes/lab11/index.md) | | | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| [Lab 12 - Helm & Kustomize](labs/kubernetes/lab12/index.md) | | :white_check_mark:¹ | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| [Lab 13 - Observability](labs/kubernetes/lab13/index.md) | | :white_check_mark:⁵ | :white_check_mark:² | Varies³ | :white_check_mark:² |
| [Lab 14 - Virtual Machines](labs/kubernetes/lab14/index.md) | | Linux + `/dev/kvm`⁴ | | Varies³ | :white_check_mark: bare metal⁴ |
| [Tekton Lab](labs/devops/tekton/index.md) | | Part 1 | :white_check_mark:² | Varies³ | :white_check_mark:² |
| [Argo CD Lab](labs/devops/argocd/index.md) | | :white_check_mark:⁵ | :white_check_mark:² | Varies³ | :white_check_mark:² |

1. Remove the OpenShift Route component from the overlays, as the lab explains.
2. Needs cluster-admin once, to install the operator or enable user workload monitoring.
3. The Developer Sandbox doesn't give you cluster-admin, so you can only use what's already installed there. Check the Sandbox's operators and features before planning a class around it.
4. VMs need hardware virtualization on the nodes. See [Virtualization](#virtualization).
5. Start the [local cluster](#local-cluster-with-kind) with `--monitoring` for Lab 13, and with `--devops` for the Argo CD lab.

## Your workstation

Every lab needs the tools on the [Prerequisites](prerequisites.md) page: Git, Podman (or Docker) and the `oc` CLI, plus `helm`, `tkn`, `argocd` and `virtctl` for the labs that use them. Run the [system check script](scripts/system-check.sh) to see what's missing.

## OpenShift options

=== "OpenShift Local"

    [OpenShift Local](https://developers.redhat.com/products/openshift-local/overview) runs a single-node OpenShift cluster on your laptop, and you're cluster-admin. It's the best free option for the DevOps and observability labs.

    - **Resources:** at least 4 CPU cores, about 11 GB of free memory and 35 GB of disk. Give it more memory if you install operators or enable monitoring.
    - **Setup:** download the installer and your pull secret from the [Red Hat Hybrid Cloud Console](https://console.redhat.com/openshift/create/local).

    ```bash
    crc config set memory 16384                     # 16 GiB: room for operators
    crc config set enable-cluster-monitoring true   # needed for Lab 13 (off by default)
    crc setup
    crc start
    eval $(crc oc-env)
    oc login -u kubeadmin https://api.crc.testing:6443   # password: crc console --credentials
    ```

    Then install the **Red Hat OpenShift Pipelines** and **Red Hat OpenShift GitOps** operators from OperatorHub for the DevOps labs, and enable user workload monitoring for Lab 13 (see the lab). OpenShift Local isn't meant for running virtual machines.

=== "Developer Sandbox"

    The [Developer Sandbox for Red Hat OpenShift](https://developers.redhat.com/developer-sandbox) is a free, hosted OpenShift environment. You need only a browser and `oc`.

    - Sign in with a free Red Hat account and start the sandbox.
    - Log in from the CLI with the web console's **Copy login command**.
    - You get a pre-created project, so use it in place of `oc new-project`.
    - You aren't a cluster administrator, so you can't install operators or change cluster settings. The DevOps, observability and virtualization labs only work if their features are already available in your sandbox.

=== "IBM Technology Zone"

    IBMers and IBM Business Partners can reserve OpenShift clusters, including bare-metal clusters for OpenShift Virtualization, from [IBM Technology Zone](https://techzone.ibm.com/). A reserved cluster gives you cluster-admin, so every lab works. It's the best choice for instructor-led classes: reserve one cluster, and give each student their own projects.

=== "Trials and managed OpenShift"

    Red Hat offers [OpenShift trials](https://www.redhat.com/en/technologies/cloud-computing/openshift/try-it) and managed OpenShift on the major clouds (ROSA on AWS, Azure Red Hat OpenShift, and Red Hat OpenShift on IBM Cloud). These are full clusters where you're an administrator, suitable for every lab.

!!! tip "Running a class on a shared cluster"
    Give each student a prefix, for example `oc new-project jd-lab1`. Install the Pipelines and GitOps operators and enable user workload monitoring once, before the class. Grant students `monitoring-edit` in their projects for Lab 13.

## Local cluster with kind

For the Kubernetes labs you don't need OpenShift at all. The bootcamp's [local cluster script](scripts/local-cluster.sh) creates a two-node [kind](https://kind.sigs.k8s.io/) cluster on Docker or Podman and installs what the labs need:

```bash
curl -LO https://ibm-cloud-architecture.github.io/cloud-native-bootcamp/scripts/local-cluster.sh
chmod +x local-cluster.sh

./local-cluster.sh                          # Kubernetes Labs 1-10
./local-cluster.sh --monitoring             # + Prometheus Operator (Lab 13)
./local-cluster.sh --devops                 # + Tekton and Argo CD (DevOps labs)
./local-cluster.sh --openshift-like         # + OpenShift-style security defaults
./local-cluster.sh --delete                 # remove the cluster
```

| Option | What it adds |
| --- | --- |
| (none) | Two-node Kubernetes cluster, default StorageClass, metrics-server |
| `--devops` | Tekton Pipelines and Triggers, Argo CD (upstream, not the OpenShift operators) |
| `--monitoring` | Prometheus Operator and a Prometheus that picks up `ServiceMonitor` and `PrometheusRule` resources in every namespace. Open it with `kubectl -n monitoring port-forward svc/prometheus-operated 9090`. |
| `--openshift-like` | Pods in namespaces labelled `openshift-like=true` get OpenShift's `restricted-v2` defaults: a random non-root UID in group 0, all capabilities dropped, and no privilege escalation. Use it to check that images will run on OpenShift. |
| `--virtualization` | KubeVirt. See below. |

Requirements: `kind`, `kubectl` and Docker or Podman. Give the Docker Desktop or Podman machine at least 4 CPUs and 8 GB of memory. Use `kubectl`, or `oc`, which works against any Kubernetes cluster. OpenShift-only APIs (Routes, BuildConfigs, `oc new-project`) aren't available.

## Virtualization

Virtual machines need **hardware virtualization** on the worker nodes:

- **OpenShift:** a cluster on bare metal, or on cloud instances that expose virtualization (for example bare-metal instance types), with the OpenShift Virtualization operator installed. IBM Technology Zone and managed OpenShift on bare-metal nodes both work.
- **Local:** `./local-cluster.sh --virtualization` installs KubeVirt. It works best on a **Linux** host with `/dev/kvm`, using Docker or rootful Podman. On macOS and Windows there's no hardware virtualization inside the container VM, so KubeVirt falls back to slow software emulation. With **rootless Podman** (the macOS default), VMs don't start at all, because KubeVirt can't create the VM's network device, so the script skips KubeVirt there. Docker Desktop and rootful Podman on macOS haven't been tested.
