---
tags:
  - Lab
  - Packaging
  - Intermediate
---

# Lab 12 - Helm & Kustomize

<span class="lab-badge">45 min</span> <span class="lab-badge">Intermediate</span>

## Problem

The `greeting` service has to run in a **dev** and a **prod** environment with different settings. You'll deploy it both ways teams do in practice: with **Kustomize** overlays, then as a **Helm** release you can upgrade and roll back.

See [Helm & Kustomize](../../../openshift/packaging/index.md) for the concepts.

## Prerequisites

- An OpenShift cluster (or Kubernetes: see the tip below) and the `oc` CLI
- The `helm` CLI, version 4. Install it with `brew install helm` on macOS, or see the [Helm install guide](https://helm.sh/docs/intro/install/).
- A clone of the bootcamp repository:

    ```bash
    git clone https://github.com/ibm-cloud-architecture/cloud-native-bootcamp.git
    cd cloud-native-bootcamp/sample-app
    ```

!!! tip "Using plain Kubernetes?"
    Everything works on kind or minikube. Remove the `components:` lines from the overlays (they add an OpenShift Route), use `kubectl` in place of `oc`, and use `kubectl port-forward` in place of the Route URLs.

## Part 1: Kustomize

1. Look at the layout, then render both overlays **without** applying them. What differs between dev and prod?

    ```bash
    find kustomize -type f
    oc kustomize kustomize/overlays/dev
    diff <(oc kustomize kustomize/overlays/dev) <(oc kustomize kustomize/overlays/prod)
    ```

2. Create a project for each environment and deploy the matching overlay.

    ??? success "Solution"
        ```bash
        oc new-project greeting-dev
        oc apply -k kustomize/overlays/dev -n greeting-dev
        oc new-project greeting-prod
        oc apply -k kustomize/overlays/prod -n greeting-prod
        oc rollout status deployment/greeting -n greeting-dev
        oc rollout status deployment/greeting -n greeting-prod
        ```

3. Call both environments through their Routes. Each should return its own greeting, and prod should have 3 pods.

    ```bash
    for env in dev prod; do
      curl -sk "https://$(oc get route greeting -n greeting-$env -o jsonpath='{.spec.host}')/greeting"; echo
    done
    oc get pods -n greeting-prod -l app=greeting
    ```

4. Change the dev greeting in `kustomize/overlays/dev/kustomization.yaml`. Before applying, preview the change with `oc diff`, then apply it. Why does the Deployment roll out new pods even though you only changed a ConfigMap value?

    ??? success "Solution"
        ```bash
        oc diff -k kustomize/overlays/dev -n greeting-dev
        oc apply -k kustomize/overlays/dev -n greeting-dev
        oc rollout status deployment/greeting -n greeting-dev
        ```

        `configMapGenerator` appends a hash of the content to the ConfigMap name, for example `greeting-config-cfm652bgbb`. A new value produces a new name, which changes the Deployment's pod template, so Kubernetes rolls out new pods that read the new value. A hand-written ConfigMap wouldn't do this, and pods would keep the old environment variables until restarted.

5. **Your turn:** create a new overlay, `kustomize/overlays/test`, that runs **2** replicas, labels everything `environment: test`, and greets with `Hello from test`. Deploy it to a `greeting-test` project.

## Part 2: Helm

6. Check and render the chart locally. Nothing is created in the cluster yet.

    ```bash
    helm lint helm/greeting
    helm template demo helm/greeting --set greeting="Hi"
    ```

7. Install the chart as a release named `greeting` in a new `greeting-helm` project, with your own greeting.

    ??? success "Solution"
        ```bash
        oc new-project greeting-helm
        helm install greeting ./helm/greeting --set greeting="Hello from Helm" --wait
        helm list
        ```

        Helm prints the chart's `NOTES.txt`, including the URL to try.

8. Upgrade the release to 2 replicas, look at the release history, and run the chart's test.

    ??? success "Solution"
        ```bash
        helm upgrade greeting ./helm/greeting --reuse-values --set replicaCount=2 --wait
        helm history greeting
        helm test greeting
        ```

        `--reuse-values` keeps the greeting you set at install time. Without it, values not passed again fall back to the chart defaults.

9. Roll back to the first revision and confirm the replica count. What revision number does the rollback create?

    ??? success "Solution"
        ```bash
        helm rollback greeting 1 --wait
        helm history greeting
        oc get deployment greeting
        ```

        The rollback creates revision **3**, a copy of revision 1. Helm never rewrites history.

10. Upgrade to the production values file, `values-prod.yaml`. It sets 3 replicas, more memory, and enables a ServiceMonitor for Prometheus, which you'll use in [Lab 13](../lab13/index.md).

    ??? success "Solution"
        ```bash
        helm upgrade --install greeting ./helm/greeting -f helm/greeting/values-prod.yaml --wait
        helm get values greeting
        ```

        If this fails with `no matches for kind "ServiceMonitor"`, the cluster doesn't have the monitoring API. Add `--set serviceMonitor.enabled=false`.

## Part 3 (optional): Let Argo CD deploy it

After you've done the [Argo CD Lab](../../devops/argocd/index.md), create an Application whose `path` is `sample-app/kustomize/overlays/dev` in your fork. Argo CD runs Kustomize for you, so you never run `oc apply -k` again. Promote a new image by changing `newTag` in the overlay and pushing the commit.

## Cleanup

```bash
helm uninstall greeting -n greeting-helm
oc delete project greeting-dev greeting-prod greeting-test greeting-helm
```

!!! note "About the image"
    The overlays and chart use `ghcr.io/ibm-cloud-architecture/cloud-native-bootcamp/greeting:v1.0.0`. To use the image you built in the [Containers Lab](../../containers/index.md) instead, set `images[].newName` in an overlay, or `--set image.repository=quay.io/<you>/greeting` with Helm.
