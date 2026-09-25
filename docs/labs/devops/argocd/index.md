# Argo CD Lab - OpenShift GitOps

<span class="lab-badge">60 min</span> <span class="lab-badge">Intermediate</span>

In this lab you'll practice **GitOps** with **Red Hat OpenShift GitOps**, Red Hat's supported distribution of [Argo CD](https://argo-cd.readthedocs.io/). You'll deploy the bootcamp's `greeting` app from manifests in Git, watch Argo CD correct drift in the cluster, and roll out changes by committing to Git instead of running `oc`.

## Prerequisites

- An OpenShift 4.16+ cluster with the **Red Hat OpenShift GitOps** operator installed. If it isn't installed and you're a cluster administrator, see [Install the operator](#install-the-operator).
- The `oc` CLI, logged in to the cluster.
- The `argocd` CLI. Install it with `brew install argocd` on macOS, or download it from the [Argo CD releases](https://github.com/argoproj/argo-cd/releases/latest).
- A GitHub account.

### Install the operator

Skip this section if OpenShift GitOps is already installed. Check with `oc get argocd -n openshift-gitops`.

=== "Web console"

    1. Log in as a cluster administrator and open **Operators > OperatorHub** (**Ecosystem > Software Catalog** on OpenShift 4.20 and later).
    2. Search for **Red Hat OpenShift GitOps**, click **Install**, and accept the defaults.
    3. Wait for the operator to show **Succeeded**.

=== "CLI"

    ```bash
    oc apply -f - <<'EOF'
    apiVersion: operators.coreos.com/v1alpha1
    kind: Subscription
    metadata:
      name: openshift-gitops-operator
      namespace: openshift-operators
    spec:
      channel: latest
      name: openshift-gitops-operator
      source: redhat-operators
      sourceNamespace: openshift-marketplace
    EOF
    ```

The operator creates a ready-to-use Argo CD instance in the `openshift-gitops` namespace:

```bash
oc get pods -n openshift-gitops
oc get route openshift-gitops-server -n openshift-gitops
```

!!! tip "Using plain Kubernetes?"
    Install upstream Argo CD with `kubectl create namespace argocd && kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`. Everywhere below, use the `argocd` namespace instead of `openshift-gitops`, and skip the `route.yaml` manifest and the namespace label.

## Setup

### 1. Fork the repository

Argo CD deploys whatever is in Git, so you need a repository you can push to. [Fork the bootcamp repository](https://github.com/ibm-cloud-architecture/cloud-native-bootcamp/fork) to your GitHub account, then clone your fork:

```bash
export GITHUB_USER=<your-github-username>
git clone https://github.com/${GITHUB_USER}/cloud-native-bootcamp.git
cd cloud-native-bootcamp
ls sample-app/gitops
```

```text
deployment.yaml  route.yaml  service.yaml
```

These three manifests are the **desired state** of the app: a Deployment of the `greeting` image, a Service, and a TLS Route.

### 2. Create the target project

```bash
oc new-project gitops-lab
oc label namespace gitops-lab argocd.argoproj.io/managed-by=openshift-gitops
```

The label lets the default Argo CD instance manage resources in `gitops-lab`. Without it, syncs fail with a `forbidden` error.

### 3. Log in to Argo CD

=== "Web console"

    Open the Argo CD URL and choose **Log in via OpenShift**:

    ```bash
    echo "https://$(oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}')"
    ```

    You can also use the application launcher (the grid icon) in the OpenShift console and select **Cluster Argo CD**.

=== "CLI"

    ```bash
    ARGOCD_SERVER=$(oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}')
    ARGOCD_PASSWORD=$(oc get secret openshift-gitops-cluster -n openshift-gitops -o jsonpath='{.data.admin\.password}' | base64 -d)
    argocd login "${ARGOCD_SERVER}" --username admin --password "${ARGOCD_PASSWORD}" --grpc-web --insecure
    ```

    `--insecure` is only needed when the cluster uses a self-signed certificate, as OpenShift Local does. Reading the admin secret requires cluster-admin rights.

## Part 1: Create an Application

An Argo CD **Application** links a path in a Git repository to a namespace in a cluster.

1. Save this Application as `greeting-app.yaml`. It's written for your fork:

    ```yaml title="greeting-app.yaml"
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: greeting
      namespace: openshift-gitops
    spec:
      project: default
      source:
        repoURL: https://github.com/GITHUB_USER/cloud-native-bootcamp.git
        targetRevision: main
        path: sample-app/gitops
      destination:
        server: https://kubernetes.default.svc
        namespace: gitops-lab
    ```

2. Put in your GitHub username and create the Application:

    ```bash
    sed -i.bak "s/GITHUB_USER/${GITHUB_USER}/" greeting-app.yaml
    oc apply -f greeting-app.yaml
    ```

3. Check the Application's status in the UI or with the CLI:

    ```bash
    argocd app get openshift-gitops/greeting
    ```

    It shows `Sync Status: OutOfSync` and `Health Status: Missing`. Argo CD has compared Git with the cluster and found that none of the resources exist yet. With no sync policy, it only reports the difference.

4. **Sync** the Application to make the cluster match Git. Click **Sync > Synchronize** in the UI, or run:

    ```bash
    argocd app sync openshift-gitops/greeting
    argocd app wait openshift-gitops/greeting --health
    ```

5. Check the app:

    ```bash
    oc get deployment,service,route -n gitops-lab
    curl -sk "https://$(oc get route greeting -n gitops-lab -o jsonpath='{.spec.host}')/greeting?name=GitOps"
    ```

    ```json
    {"message":"Deployed by Argo CD","name":"GitOps"}
    ```

## Part 2: Automated sync and self-healing

1. Turn on automated sync with **prune** (delete resources that were removed from Git) and **self-heal** (undo manual changes in the cluster):

    ```bash
    argocd app set openshift-gitops/greeting --sync-policy automated --auto-prune --self-heal
    ```

    Declaratively, that's this block in the Application's `spec`:

    ```yaml
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
    ```

2. Simulate someone "fixing" production by hand:

    ```bash
    oc scale deployment/greeting --replicas=3 -n gitops-lab
    oc get deployment greeting -n gitops-lab -w
    ```

    Within a few seconds, Argo CD notices that the cluster has **drifted** from Git and scales the Deployment back to 1 replica. Press ++ctrl+c++ to stop watching.

## Part 3: Change the app through Git

In GitOps, Git is the only way to change what runs.

1. In your clone, edit `sample-app/gitops/deployment.yaml`: set `replicas: 2` and change the `GREETING` value to a message of your own.
2. Commit and push:

    ```bash
    git add sample-app/gitops/deployment.yaml
    git commit -m "Scale greeting to 2 replicas and update message"
    git push
    ```

3. Argo CD polls Git every 3 minutes. Click **Refresh** in the UI, or run `argocd app get openshift-gitops/greeting --refresh`, to check right away. Watch the new replicas roll out:

    ```bash
    oc get pods -n gitops-lab -l app=greeting
    curl -sk "https://$(oc get route greeting -n gitops-lab -o jsonpath='{.spec.host}')/greeting"
    ```

4. See the deployment history. Each sync records the Git commit it deployed:

    ```bash
    argocd app history openshift-gitops/greeting
    ```

5. **Roll back the GitOps way**: revert the commit and push. Argo CD brings the cluster back in line with Git.

    ```bash
    git revert --no-edit HEAD
    git push
    ```

!!! tip "Deploy your own image"
    Change the `image` in `deployment.yaml` to the `quay.io/<your-username>/greeting:v1.0.0` image you pushed in the [Containers Lab](../../containers/index.md), then commit and push. This is how CI and CD connect: a pipeline builds the image, and a commit to the GitOps repository deploys it.

## Part 4: Prune

1. Delete `sample-app/gitops/route.yaml` from your fork, then commit and push.
2. After the next sync, the Route is gone from the cluster (`oc get route -n gitops-lab`), because `prune` is on.
3. Restore it with `git revert --no-edit HEAD && git push`.

## Cleanup

```bash
oc delete -f greeting-app.yaml       # deletes the Application only
oc delete project gitops-lab
```

!!! note
    Deleting an Application doesn't delete the resources it deployed, unless the Application has the `resources-finalizer.argocd.argoproj.io` finalizer. Deleting the project removes everything.

## What you learned

- [x] Declaring an Argo CD Application that points at a Git path
- [x] Manual vs. automated sync, self-heal and prune
- [x] Changing and rolling back an application by committing to Git
- [x] How CI (building images) and CD (GitOps) fit together

## Additional resources

- [Red Hat OpenShift GitOps documentation](https://docs.redhat.com/en/documentation/red_hat_openshift_gitops/)
- [Argo CD documentation](https://argo-cd.readthedocs.io/en/stable/)
- [OpenGitOps principles](https://opengitops.dev/)
