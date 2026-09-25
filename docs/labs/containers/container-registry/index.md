---
tags:
  - Lab
  - Containers
  - Registries
  - OpenShift
  - Intermediate
---

# Image Registry Lab

<span class="lab-badge">40 min</span> <span class="lab-badge">Intermediate</span>

In the [Containers Lab](../index.md) you pushed the `greeting` image to Quay.io. In this lab you'll run that image on OpenShift, pull it from a **private** repository with a pull secret, and then build the image **inside the cluster** and store it in OpenShift's internal registry.

## Prerequisites

- You've finished the [Containers Lab](../index.md), and `quay.io/<your-username>/greeting:v1.0.0` exists and is **public**. If you built it on an Apple Silicon Mac, build it for `linux/amd64` (or multi-arch), as described at the end of that lab.
- You're logged in to an OpenShift cluster with `oc`. See [lab environment options](../../kubernetes/index.md#lab-environment).
- You still have the `greeting` directory with `main.go`, `go.mod` and `Containerfile`.

```bash
export QUAY_USER=<your-username>
oc new-project registry-lab
```

## Part 1: Deploy an image from a public registry

1. Create a Deployment named `greeting` from your Quay image, with container port `8080`.

    ??? success "Solution"
        ```bash
        oc create deployment greeting --image=quay.io/${QUAY_USER}/greeting:v1.0.0 --port=8080
        oc rollout status deployment/greeting
        ```

2. Expose the Deployment as a Service, then expose the Service as a Route.

    ??? success "Solution"
        ```bash
        oc expose deployment greeting --port=8080
        oc expose service greeting
        ```

3. Call the app through its Route:

    ```bash
    curl "http://$(oc get route greeting -o jsonpath='{.spec.host}')/greeting?name=OpenShift"
    ```

    ```json
    {"message":"Welcome to the Cloud Native Bootcamp!","name":"OpenShift"}
    ```

## Part 2: Pull from a private repository

Most company images live in private repositories. The cluster needs credentials, a **pull secret**, to download them.

4. On [quay.io](https://quay.io/), open the `greeting` repository, go to **Settings**, and make it **private**.

5. Force a new pull by restarting the Deployment. The new pod fails to start. Find out why.

    ??? success "Solution"
        ```bash
        oc rollout restart deployment/greeting
        oc get pods
        oc describe pod -l app=greeting | grep -A 5 Events
        ```

        The new pod shows `ErrImagePull` / `ImagePullBackOff`, with an `unauthorized` error in the events. The old pod keeps serving traffic, because the rolling update never removes the working pod before its replacement is ready.

6. Create a robot account with read access to the repository:

    1. In Quay, open **Account Settings > Robot Accounts** and create a robot account, for example `openshift_puller`.
    2. Give it **Read** permission on the `greeting` repository.
    3. Open the robot account and copy its username (`<your-username>+openshift_puller`) and token.

    Robot accounts are better than your personal password: each one is scoped to specific repositories and can be revoked on its own.

7. Create a pull secret named `quay-pull` from the robot credentials, and link it to the `default` ServiceAccount for pulling images.

    ??? success "Solution"
        ```bash
        oc create secret docker-registry quay-pull \
          --docker-server=quay.io \
          --docker-username="${QUAY_USER}+openshift_puller" \
          --docker-password='<robot-token>'
        oc secrets link default quay-pull --for=pull
        ```

        `oc secrets link` adds the secret to the ServiceAccount's `imagePullSecrets`. Every pod that runs as that ServiceAccount can then pull with it. You could also list the secret under `spec.imagePullSecrets` in each Pod template.

8. Delete the failing pod so it's recreated with the pull secret, and check that the rollout completes.

    ??? success "Solution"
        ```bash
        oc delete pod -l app=greeting --field-selector=status.phase=Pending
        oc rollout status deployment/greeting
        ```

## Part 3: Build inside the cluster

OpenShift can build images itself, without Podman on your laptop and without an external registry. A **BuildConfig** describes the build. The result goes into the cluster's **internal registry**, where an **ImageStream** tracks it.

9. From inside your `greeting` directory, create a binary build named `greeting-internal` that uses your Containerfile.

    ??? success "Solution"
        ```bash
        cd greeting
        oc new-build --name=greeting-internal --binary --strategy=docker
        ```

        `--binary` means the source is uploaded from your machine when the build starts, not cloned from Git.

10. Start the build, upload the current directory, and follow the build log.

    ??? success "Solution"
        ```bash
        oc start-build greeting-internal --from-dir=. --follow
        ```

        The log ends with `Push successful`. The image was pushed to `image-registry.openshift-image-registry.svc:5000/registry-lab/greeting-internal`.

11. Look at the ImageStream that tracks the image.

    ??? success "Solution"
        ```bash
        oc get imagestream greeting-internal
        oc describe imagestream greeting-internal
        ```

12. Deploy the image from the ImageStream with a custom greeting, and expose it.

    ??? success "Solution"
        ```bash
        oc new-app greeting-internal --name=greeting-internal -e GREETING="Built on OpenShift"
        oc expose service greeting-internal
        curl "http://$(oc get route greeting-internal -o jsonpath='{.spec.host}')/greeting"
        ```

        ```json
        {"message":"Built on OpenShift","name":"World"}
        ```

        `oc new-app` creates a Deployment and a Service. Because the Deployment uses an ImageStream tag, a later build automatically rolls out the new image.

!!! tip "Builds from Git"
    Instead of uploading a local directory, you can build straight from a Git repository: `oc new-build https://github.com/<you>/<repo>.git --strategy=docker`. In the [Tekton lab](../../devops/tekton/index.md) you'll automate build and deploy with a pipeline.

## Cleanup

```bash
oc delete project registry-lab
```

## What you learned

- [x] Deploying and exposing an image from a public registry
- [x] Pulling from private registries with robot accounts and pull secrets
- [x] Building images in-cluster with BuildConfigs, ImageStreams and the internal registry
