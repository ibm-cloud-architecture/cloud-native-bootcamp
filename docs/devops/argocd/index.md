---
tags:
  - GitOps
  - Argo CD
---

# Continuous Deployment

Continuous Integration, Delivery, and Deployment are important devOps practices and we often hear a lot about them. These processes are valuable and ensures that the software is up to date timely.

- **Continuous Integration** is an automation process which allows developers to integrate their work into a repository. When a developer pushes his work into the source code repository, it ensures that the software continues to work properly. It helps to enable collaborative development across the teams and also helps to identify the integration bugs sooner.
- **Continuous Delivery** comes after Continuous Integration. It prepares the code for release. It automates the steps that are needed to deploy a build.
- **Continuous Deployment** is the final step which succeeds Continuous Delivery. It automatically deploys the code whenever a code change is done. Entire process of deployment is automated.

## What is GitOps?
GitOps in short is a set of practices to use Git pull requests to manage infrastructure and application configurations. Git repository in GitOps is considered the only source of truth and contains the entire state of the system so that the trail of changes to the system state are visible and auditable.

- Traceability of changes in GitOps is no novelty in itself as this approach is almost universally employed for the application source code. However GitOps advocates applying the same principles (reviews, pull requests, tagging, etc) to infrastructure and application
configuration so that teams can benefit from the same assurance as they do for the application source code.
- Although there is no precise definition or agreed upon set of rules, the following principles are an approximation of what constitutes a GitOps practice:
  - Declarative description of the system is stored in Git (configs, monitoring, etc)
  - Changes to the state are made via pull requests
  - Git push reconciled with the state of the running system with the state in the Git repository

## Argo CD Overview

[Argo CD](https://argo-cd.readthedocs.io/) is a declarative, GitOps continuous delivery tool for Kubernetes. It automates the deployment of applications by continuously monitoring Git repositories and synchronizing the desired application state with the live state in Kubernetes clusters.

### Key Features

- **Declarative and version controlled** - Application definitions, configurations, and environments are declarative and version controlled in Git
- **Automated deployment** - Automatically syncs application state from Git to Kubernetes
- **Multi-cluster support** - Manage deployments across multiple Kubernetes clusters
- **SSO Integration** - Integrates with OIDC, OAuth2, LDAP, SAML 2.0, GitHub, GitLab, and Microsoft
- **Rollback capabilities** - Roll back to any application state committed in the Git repository
- **Health status analysis** - Real-time view of application deployment health
- **Web UI and CLI** - Visualize and manage applications through a web interface or command line
- **Webhook integration** - Trigger deployments automatically from Git events

### How Argo CD Works

1. You define your application's desired state in a Git repository (Kubernetes manifests, Helm charts, or Kustomize)
2. ArgoCD continuously monitors the Git repository for changes
3. When changes are detected, ArgoCD compares the desired state with the live state
4. ArgoCD automatically or manually syncs the cluster to match the desired state
5. You can visualize the sync status and health of your applications in real-time

On OpenShift, Argo CD is delivered as **[Red Hat OpenShift GitOps](https://docs.redhat.com/en/documentation/red_hat_openshift_gitops/)**. The operator installs a cluster-wide Argo CD instance in the `openshift-gitops` namespace, integrates its login with OpenShift, and lets teams run their own Argo CD instances.

## Presentations

[GitOps Overview :fontawesome-regular-file-pdf:](../materials/05-Understanding-GitOps.pdf){ .md-button target="_blank"}

## Activities

These activities give you a chance to deliver an application with Argo CD using GitOps.

These tasks assume that you have:
 - Reviewed the Continuous Deployment concept page.

| Lab | Description |
| --- | ----------- |
| [Argo CD Lab](../../labs/devops/argocd/index.md) | Deploy, self-heal and update an app with OpenShift GitOps |

Once you have completed these tasks, you will have deployed an application with Argo CD and have an understanding of Continuous Deployment.
