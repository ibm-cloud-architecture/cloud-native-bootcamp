# Labs

Every lab is hands-on and runs on OpenShift, or on any Kubernetes cluster where noted. See [Lab Environments](../lab-environments.md) for which environment each lab needs and how to get one.

## Containers

| Lab | Description | Time |
| --- | ----------- | ---- |
| [Containers Lab](containers/index.md) | Build, run, inspect and push a container image with Podman or Docker | 45 min |
| [Image Registry Lab](containers/container-registry/index.md) | Deploy from Quay.io, use pull secrets, and build inside OpenShift | 40 min |

## Kubernetes & OpenShift

| Lab | Description | Time |
| --- | ----------- | ---- |
| [Lab 1 - Pod Creation](kubernetes/lab1/index.md) | Write a Pod manifest that meets a set of requirements | 15 min |
| [Lab 2 - Probes](kubernetes/lab2/index.md) | Add liveness and readiness probes to recover from an unhealthy app | 20 min |
| [Lab 3 - Debugging](kubernetes/lab3/index.md) | Find and fix everything that's broken in a deployment | 30 min |
| [Lab 4 - Multi-Container Pods](kubernetes/lab4/index.md) | Use the ambassador pattern to expose a legacy app | 30 min |
| [Lab 5 - Persistent Storage](kubernetes/lab5/index.md) | Give a PostgreSQL pod storage that survives restarts | 30 min |
| [Lab 6 - Pod Configuration](kubernetes/lab6/index.md) | Wire up ConfigMaps, Secrets, resource limits and a ServiceAccount | 30 min |
| [Lab 7 - Rolling Updates](kubernetes/lab7/index.md) | Roll out a new version, then roll back a bad one | 25 min |
| [Lab 8 - Cron Jobs](kubernetes/lab8/index.md) | Run a periodic task with a CronJob | 20 min |
| [Lab 9 - Services](kubernetes/lab9/index.md) | Expose deployments inside and outside the cluster | 25 min |
| [Lab 10 - Network Policies](kubernetes/lab10/index.md) | Allow only labelled clients to reach a secure pod | 30 min |
| [Lab 11 - Routes & Ingress](kubernetes/lab11/index.md) | Publish an app with an OpenShift Route and a Kubernetes Ingress | 30 min |
| [Lab 12 - Helm & Kustomize](kubernetes/lab12/index.md) | Deploy one app to dev and prod with Kustomize, then manage it as a Helm release | 45 min |
| [Lab 13 - Observability](kubernetes/lab13/index.md) | Scrape metrics, fire an alert, trace a slow request, and correlate logs | 45 min |
| [Lab 14 - Virtual Machines](kubernetes/lab14/index.md) | Run a VM next to your containers and expose a service it runs | 45 min |

Stuck? See the [lab solutions](kubernetes/lab-solutions.md).

## Continuous Integration

| Lab | Description | Time |
| --- | ----------- | ---- |
| [Tekton Lab](devops/tekton/index.md) | Build and deploy an app from Git with OpenShift Pipelines | 60 min |

## Continuous Delivery

| Lab | Description | Time |
| --- | ----------- | ---- |
| [Argo CD Lab](devops/argocd/index.md) | Deploy, self-heal and update an app with OpenShift GitOps | 60 min |

## Projects

| Project | Description |
| ------- | ----------- |
| [Cloud Native Challenge](../cloudnative-challenge.md) | Build, containerize, deploy and automate your own application using everything you've learned |
