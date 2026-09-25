# Kubernetes & OpenShift Labs

These hands-on labs let you practice the concepts from the Kubernetes/OpenShift section. Each lab describes a problem and the requirements to meet, but not every command. Use the course material and the official docs to work it out, then check your answer against the solution.

## Lab environment

The labs are written for **Red Hat OpenShift 4.x** and use the `oc` CLI. Any of these clusters works:

| Option | Notes |
| --- | --- |
| [OpenShift Local](https://developers.redhat.com/products/openshift-local/overview) | Single-node OpenShift on your laptop. Needs about 4 CPUs, 11 GB of RAM and a free Red Hat account. |
| [Developer Sandbox for Red Hat OpenShift](https://developers.redhat.com/developer-sandbox) | Free, hosted and nothing to install. You get a pre-created project, so use it instead of running `oc new-project`. |
| A shared OpenShift cluster | Ask your instructor for the login command. |

!!! tip "Using plain Kubernetes instead?"
    Every lab except [Lab 11](lab11/index.md) also works on upstream Kubernetes (kind, minikube, or a managed service). Replace `oc` with `kubectl`, and replace `oc new-project <name>` with `kubectl create namespace <name>` followed by `kubectl config set-context --current --namespace=<name>`.

All lab images are multi-architecture (x86_64 and ARM64) and run as a random non-root user, so they work under OpenShift's default `restricted-v2` security context constraint.

!!! note "Start each lab in its own project"
    Run `oc new-project <lab-name>` before you start a lab. This keeps the labs from interfering with each other, and cleanup is a single `oc delete project <lab-name>`.

## Labs

| Lab | Topic | Description |
| --- | ----- | ----------- |
| Lab 1 | [Pod Creation](lab1/index.md) | Write a Pod manifest that meets a set of requirements. |
| Lab 2 | [Probes](lab2/index.md) | Add liveness and readiness probes to recover from an unhealthy app. |
| Lab 3 | [Debugging](lab3/index.md) | Find and fix everything that's broken in a deployment. |
| Lab 4 | [Multi-Container Pods](lab4/index.md) | Use the ambassador pattern to expose a legacy app on a new port. |
| Lab 5 | [Persistent Storage](lab5/index.md) | Give a PostgreSQL pod storage that survives restarts. |
| Lab 6 | [Pod Configuration](lab6/index.md) | Wire up ConfigMaps, Secrets, resource limits and a ServiceAccount. |
| Lab 7 | [Rolling Updates](lab7/index.md) | Roll out a new version, then roll back a bad one. |
| Lab 8 | [Cron Jobs](lab8/index.md) | Run a periodic task with a CronJob. |
| Lab 9 | [Services](lab9/index.md) | Expose deployments inside and outside the cluster. |
| Lab 10 | [Network Policies](lab10/index.md) | Allow only labelled clients to reach a secure pod. |
| Lab 11 | [Routes & Ingress](lab11/index.md) | Publish an app with an OpenShift Route and a Kubernetes Ingress. |

## Solutions

Stuck? The [lab solutions](lab-solutions.md) have a worked answer for every lab. Try the lab yourself first.
