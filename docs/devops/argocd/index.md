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

## ArgoCD Overview

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. It automates the deployment of applications by continuously monitoring Git repositories and synchronizing the desired application state with the live state in Kubernetes clusters.

### Key Features

- **Declarative and version controlled** - Application definitions, configurations, and environments are declarative and version controlled in Git
- **Automated deployment** - Automatically syncs application state from Git to Kubernetes
- **Multi-cluster support** - Manage deployments across multiple Kubernetes clusters
- **SSO Integration** - Integrates with OIDC, OAuth2, LDAP, SAML 2.0, GitHub, GitLab, and Microsoft
- **Rollback capabilities** - Roll back to any application state committed in the Git repository
- **Health status analysis** - Real-time view of application deployment health
- **Web UI and CLI** - Visualize and manage applications through a web interface or command line
- **Webhook integration** - Trigger deployments automatically from Git events

### How ArgoCD Works

1. You define your application's desired state in a Git repository (Kubernetes manifests, Helm charts, or Kustomize)
2. ArgoCD continuously monitors the Git repository for changes
3. When changes are detected, ArgoCD compares the desired state with the live state
4. ArgoCD automatically or manually syncs the cluster to match the desired state
5. You can visualize the sync status and health of your applications in real-time

## Presentations

[GitOps Overview :fontawesome-regular-file-pdf:](../materials/05-Understanding-GitOps.pdf){ .md-button target=_blank}

## Activities

These activities give you a chance to walkthrough building CD pipelines using ArgoCD.

These tasks assume that you have:
 - Reviewed the Continuous Deployment concept page.

| Task                            | Description         | Link        | Time    |
| --------------------------------| ------------------  |:----------- |---------|
| ***Walkthroughs***                         |         |         |     |
| GitOps | Introduction to GitOps with OpenShift | [Learn OpenShift GitOps](https://docs.openshift.com/gitops/1.13/understanding_openshift_gitops/about-redhat-openshift-gitops.html){:target="_blank"} | 20 min |
| ***Try It Yourself***                         |         |         |     |
| ArgoCD Lab | Learn how to setup ArgoCD and Deploy Application | [ArgoCD](../../labs/devops/argocd/index.md) | 30 min |

Once you have completed these tasks, you will have created an ArgoCD deployment and have an understanding of Continuous Deployment.
