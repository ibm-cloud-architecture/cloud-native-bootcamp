# Continuous Integration

Continuous Integration, Delivery, and Deployment are important devOps practices and we often hear a lot about them. These processes are valuable and ensures that the software is up to date timely.

- **Continuous Integration** is an automation process which allows developers to integrate their work into a repository. When a developer pushes his work into the source code repository, it ensures that the software continues to work properly. It helps to enable collaborative development across the teams and also helps to identify the integration bugs sooner.
- **Continuous Delivery** comes after Continuous Integration. It prepares the code for release. It automates the steps that are needed to deploy a build.
- **Continuous Deployment** is the final step which succeeds Continuous Delivery. It automatically deploys the code whenever a code change is done. Entire process of deployment is automated.

## Tekton Overview

[Tekton](https://tekton.dev/) is an open source, Kubernetes-native framework for building CI/CD systems, and a graduated project of the Continuous Delivery Foundation. Pipelines are defined as Kubernetes resources (`Task`, `Pipeline`, `PipelineRun`), and every step runs in its own container, so builds are reproducible and scale with the cluster.

- **Tekton Pipelines**: the core building blocks: Steps, Tasks, Pipelines, Workspaces and Results
- **Tekton Triggers**: start pipelines from events such as Git webhooks
- **Tekton CLI (`tkn`)**: create, start and inspect pipelines from the terminal
- **Resolvers**: reuse Tasks and Pipelines stored in the cluster, in Git, in OCI bundles or on [Artifact Hub](https://artifacthub.io/packages/search?kind=7)

On OpenShift, Tekton is delivered as **[Red Hat OpenShift Pipelines](https://docs.redhat.com/en/documentation/red_hat_openshift_pipelines/)**. It adds a curated set of Tasks (such as `git-clone`, `buildah` and `openshift-client`), a pipeline builder and log viewer in the web console, and **[Pipelines as Code](https://pipelinesascode.com/)**, which runs the pipelines stored in your Git repository on every push and pull request.

## Presentations

[Tekton Overview :fontawesome-regular-file-pdf:](../materials/04-Tekton-Overview.pdf){ .md-button target="_blank"}

## Activities

The continuous integration activities focus around Tekton the integration platform. These labs will show you how to build pipelines and test your code before deployment.

These tasks assume that you have:

- Reviewed the continuous integration concept page.
- Access to an OpenShift cluster with OpenShift Pipelines installed (see the lab prerequisites).

| Task | Description | Link | Time |
| ---- | ----------- | :--- | ---- |
| ***Try It Yourself*** | | | |
| In-cluster builds | Build an image inside OpenShift with a BuildConfig | [Image Registry Lab, Part 3](../../labs/containers/container-registry/index.md#part-3-build-inside-the-cluster) | 20 min |
| Tekton Lab | Build and deploy an app with OpenShift Pipelines | [Tekton Lab](../../labs/devops/tekton/index.md) | 1 hour |

Once you have completed these tasks, you will have an understanding of continuous integration and how to use Tekton to build a pipeline.
