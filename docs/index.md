# IBM Cloud Native Bootcamp

## Bootcamp Overview

This Cloud Native Bootcamp teaches IBMers, Business Partners and clients what it takes to build and run applications in the cloud. You'll come away with hands-on experience in each technology below: packaging apps in containers, running them on Kubernetes and Red Hat OpenShift, and automating delivery with CI/CD pipelines and GitOps.

!!! tip "Start here"
    Set up your workstation and get an OpenShift cluster on the [Prerequisites](prerequisites.md) page, then follow the [Course Agenda](agenda.md) or jump straight into the [Labs](labs/index.md).

## Concepts Covered

<div class="grid cards" markdown>

-   :octicons-cloud-24:{ .lg .middle } __Cloud Native__

    ---

    Moving to the cloud comes with new concepts and standards that should be understood before starting your journey to cloud.

    [:octicons-arrow-right-24: Getting started](./cloud/index.md)

-   :octicons-container-24:{ .lg .middle } __Containers__

    ---

    The first step when moving to the cloud is getting your applications running in containers. Build, run and share images with Podman.

    [:octicons-arrow-right-24: Containerization](./containers/index.md)

-   :simple-redhatopenshift:{ .lg .middle } __Kubernetes/OpenShift__

    ---

    Managing hundreds of containers by hand is chaos. Learn how Kubernetes and OpenShift schedule, heal, scale and expose them.

    [:octicons-arrow-right-24: Container Orchestration](./openshift/index.md)

-   :octicons-git-compare-24:{ .lg .middle } __DevOps/GitOps__

    ---

    Automate builds with Tekton (OpenShift Pipelines) and deployments with Argo CD (OpenShift GitOps).

    [:octicons-arrow-right-24: DevOps](./devops/index.md)

</div>

## Hands-on Labs

<div class="grid cards" markdown>

-   :material-flask-outline:{ .lg .middle } __15 labs, tested end to end__

    ---

    From your first container image to a GitOps-managed deployment. Every lab runs on OpenShift, uses multi-architecture images, and has a worked solution.

    [:octicons-arrow-right-24: Browse the labs](./labs/index.md)

-   :material-trophy-outline:{ .lg .middle } __Cloud Native Challenge__

    ---

    Put it all together: build your own app, containerize it, deploy it to OpenShift, and automate its delivery.

    [:octicons-arrow-right-24: Take the challenge](./cloudnative-challenge.md)

-   :material-source-repository:{ .lg .middle } __Sample application__

    ---

    The `greeting` service used across the container, Tekton and Argo CD labs lives in the repository's `sample-app/` folder.

    [:octicons-arrow-right-24: View on GitHub](https://github.com/ibm-cloud-architecture/cloud-native-bootcamp/tree/main/sample-app)

</div>

## How to approach the Bootcamp

This bootcamp is designed to give you a better hands-on experience than copy and paste. It follows a "read, listen, watch, try it out" approach: learn the concepts, then use your resources to solve the labs on your own with as little instruction as possible. Each lab states a problem and its requirements. Work out the commands yourself, then check your answer against the solution.
