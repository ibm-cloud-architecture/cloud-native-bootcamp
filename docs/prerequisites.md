# Prerequisites

## Required skills

The labs assume you're comfortable working at the command line in a Linux-style shell (Bash, Zsh or similar). You should be able to:

- Navigate directories and copy, move and rename files
- Understand Linux file permissions
- Edit text files with a terminal or graphical editor
- Set environment variables and understand `$PATH`

If you need a refresher, try [The Linux command line for beginners](https://ubuntu.com/tutorials/command-line-for-beginners).

!!! tip "Windows users"
    Use [Windows Subsystem for Linux (WSL 2)](https://learn.microsoft.com/windows/wsl/install) with an Ubuntu distribution. All commands in the bootcamp are written for a Bash-compatible shell, and they work unchanged in WSL.

## Accounts

| Account | Used for |
| --- | --- |
| [GitHub](https://github.com/signup) | Forking the bootcamp repository in the Argo CD and Tekton labs, and hosting your own code |
| [Quay.io](https://quay.io/) | Pushing container images in the container labs |
| [Red Hat Developer](https://developers.redhat.com/register) | OpenShift Local and the Developer Sandbox (free) |

## Tools

| Tool | Purpose | Required? |
| --- | --- | --- |
| [Git](https://git-scm.com/downloads) | Source control | Yes |
| [Podman](https://podman.io/docs/installation) or [Podman Desktop](https://podman-desktop.io/) | Building and running containers. [Docker](https://docs.docker.com/get-started/get-docker/) also works. | Yes |
| [OpenShift CLI (`oc`)](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/) | Working with OpenShift. It includes all `kubectl` functionality. | Yes |
| [Tekton CLI (`tkn`)](https://tekton.dev/docs/cli/) | Tekton Lab | For the CI lab |
| [Argo CD CLI (`argocd`)](https://argo-cd.readthedocs.io/en/stable/cli_installation/) | Argo CD Lab | For the CD lab |
| [Visual Studio Code](https://code.visualstudio.com/) | Editing code and YAML. Add the Red Hat YAML extension for Kubernetes schema validation. | Recommended |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | Only needed if you use a non-OpenShift cluster | Optional |

=== "macOS"

    With [Homebrew](https://brew.sh/):

    ```bash
    brew install git podman openshift-cli tektoncd-cli argocd
    brew install --cask podman-desktop visual-studio-code
    podman machine init && podman machine start
    ```

=== "Linux"

    Install Git and Podman with your distribution's package manager, for example on Fedora or RHEL:

    ```bash
    sudo dnf install -y git podman
    ```

    Then download `oc` from the [OpenShift mirror](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/) (`openshift-client-linux-*.tar.gz`), and `tkn` and `argocd` from their release pages linked in the table. Extract each binary into a directory on your `PATH`, such as `~/.local/bin`.

=== "Windows (WSL 2)"

    Inside your WSL Ubuntu shell:

    ```bash
    sudo apt update && sudo apt install -y git podman
    ```

    Then download the Linux builds of `oc`, `tkn` and `argocd`, as described in the Linux tab. Alternatively, install [Podman Desktop for Windows](https://podman-desktop.io/docs/installation/windows-install), which manages a Podman machine in WSL for you.

### Check your setup

Download and run the system check script. It reports which tools are installed and where to get the missing ones:

[Download System Check Script :fontawesome-solid-download:](scripts/system-check.sh){ .md-button download }

```bash
chmod +x system-check.sh
./system-check.sh
```

## Get a cluster

The labs are written for **Red Hat OpenShift 4.x**. Choose one of these options:

=== "OpenShift Local"

    [OpenShift Local](https://developers.redhat.com/products/openshift-local/overview) runs a single-node OpenShift cluster on your laptop. It supports macOS (Intel and Apple Silicon), Windows and Linux.

    - **Resources:** 4 CPU cores, about 11 GB of free memory, and 35 GB of disk
    - **Setup:** download the installer and your **pull secret** from the [Red Hat Hybrid Cloud Console](https://console.redhat.com/openshift/create/local), then run:

    ```bash
    crc setup
    crc start                  # paste your pull secret when prompted
    eval $(crc oc-env)         # put the bundled oc on your PATH
    crc console --credentials  # shows the oc login commands for developer and kubeadmin
    ```

    Log in as `kubeadmin` to install the operators needed by the Tekton and Argo CD labs.

=== "Developer Sandbox"

    The [Developer Sandbox for Red Hat OpenShift](https://developers.redhat.com/developer-sandbox) is a free, hosted OpenShift environment. It needs nothing but a browser and the `oc` CLI.

    1. Sign in with your Red Hat account and start the sandbox.
    2. In the web console, click your user name > **Copy login command**, then run the `oc login` command it shows.
    3. You get a pre-created project. Use it instead of running `oc new-project` in the labs.

    You aren't a cluster administrator in the Sandbox, so you can't install operators or create extra projects.

=== "Shared cluster"

    Your instructor may provide a shared OpenShift cluster for the class.

    1. Open the web console URL you were given, click your user name > **Copy login command**, and run the `oc login --token=... --server=...` command.
    2. Create projects with your initials as a prefix to avoid name clashes, for example `oc new-project jd-lab1`.

=== "Plain Kubernetes"

    Labs 1–10 and the container labs also work on upstream Kubernetes, for example [kind](https://kind.sigs.k8s.io/) running on Podman:

    ```bash
    brew install kind            # or see the kind install docs
    KIND_EXPERIMENTAL_PROVIDER=podman kind create cluster --name bootcamp
    ```

    Use `kubectl` in place of `oc`, and `kubectl create namespace` in place of `oc new-project`. Lab 11 (Routes) and the OpenShift-specific parts of the Image Registry, Tekton and Argo CD labs need OpenShift.

Verify that you're connected:

```bash
oc whoami
oc version
```

## Next steps

Once your setup is complete, start with [Cloud Native](cloud/index.md) concepts, or go straight to the [labs](labs/index.md).
