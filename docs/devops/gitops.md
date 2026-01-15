# What is GitOps

GitOps is a modern approach to continuous deployment that uses Git as the single source of truth for declarative infrastructure and application configurations. It extends the principles that development teams already use for application source code—version control, code review, and collaboration—to infrastructure and operations.

In a GitOps workflow, the desired state of your entire system is stored in Git repositories. Any changes to the system are made through pull requests, which provide an audit trail and enable collaboration. Automated processes then ensure that the actual state of the running system matches the desired state defined in Git.

## Core Principles of GitOps

GitOps is built on four key principles:

1. **Declarative Configuration** - The entire system, including infrastructure and applications, is described declaratively. This means you define *what* you want, not *how* to achieve it.

2. **Version Controlled** - All configuration is stored in Git, providing a complete history of changes, the ability to rollback, and an audit trail for compliance.

3. **Automated Delivery** - Approved changes are automatically applied to the system. Once a pull request is merged, the deployment happens without manual intervention.

4. **Software Agents** - Software agents (like ArgoCD or Flux) continuously monitor the actual state and reconcile any drift from the desired state stored in Git.

## How GitOps Works

The typical GitOps workflow follows these steps:

1. A developer makes changes to the application or infrastructure configuration
2. The changes are submitted as a pull request to the Git repository
3. The team reviews and approves the pull request
4. Once merged, an automated agent detects the change
5. The agent applies the changes to the target environment
6. The agent continuously monitors and ensures the running state matches Git

```text
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  Developer   │───▶│     Git      │───▶│  GitOps      │
│  makes       │    │  Repository  │    │  Agent       │
│  changes     │    │  (PR/Merge)  │    │  (ArgoCD)    │
└──────────────┘    └──────────────┘    └──────┬───────┘
                                               │
                                               ▼
                                        ┌──────────────┐
                                        │  Kubernetes  │
                                        │  Cluster     │
                                        │  (Deployed)  │
                                        └──────────────┘
```

## GitOps vs Traditional CI/CD

| Aspect | Traditional CI/CD | GitOps |
| ------ | ----------------- | ------ |
| Source of Truth | CI/CD pipeline configuration | Git repository |
| Deployment Trigger | Pipeline execution | Git commit/merge |
| State Management | Imperative (push-based) | Declarative (pull-based) |
| Drift Detection | Manual or scripted | Automatic and continuous |
| Rollback | Re-run previous pipeline | Git revert |
| Audit Trail | Pipeline logs | Git history |

# Benefits of GitOps

Adopting GitOps provides numerous advantages for development and operations teams:

## Increased Reliability

- **Consistent deployments** - The same declarative configuration is applied every time, eliminating "works on my machine" issues
- **Easy rollbacks** - If something goes wrong, simply revert the Git commit to restore the previous working state
- **Drift detection** - Agents automatically detect and correct any unauthorized changes to the running system

## Enhanced Security

- **Reduced access requirements** - Developers don't need direct access to clusters; they only need access to Git
- **Complete audit trail** - Every change is tracked in Git with who made it, when, and why
- **Pull request reviews** - All changes go through code review before being applied

## Improved Developer Experience

- **Familiar workflows** - Developers use the same Git-based workflows they already know
- **Self-service deployments** - Teams can deploy by simply merging a pull request
- **Faster onboarding** - New team members can understand the system by reading the Git repository

## Operational Benefits

- **Disaster recovery** - The entire system state can be recreated from Git
- **Multi-cluster management** - Easily manage configurations across multiple environments
- **Compliance** - Git history provides the documentation needed for audits

## Common GitOps Tools

Several tools implement GitOps principles:

- **ArgoCD** - A declarative, GitOps continuous delivery tool for Kubernetes
- **Flux** - A set of continuous delivery solutions for Kubernetes
- **Jenkins X** - CI/CD solution with built-in GitOps capabilities
- **Tekton** - Kubernetes-native CI/CD building blocks that can be used in GitOps workflows

## Getting Started with GitOps

To begin your GitOps journey:

1. Store all your Kubernetes manifests or Helm charts in a Git repository
2. Set up a GitOps agent (like ArgoCD) in your cluster
3. Configure the agent to watch your Git repository
4. Make changes through pull requests and let the agent handle deployments

For hands-on experience with GitOps, check out the [ArgoCD Lab](../labs/devops/argocd/index.md) in this bootcamp.
