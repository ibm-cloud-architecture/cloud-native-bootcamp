---
tags:
  - Packaging
  - Kubernetes
---

# Helm & Kustomize

A real application is more than one YAML file: a Deployment, a Service, a Route, ConfigMaps, Secrets, maybe a ServiceMonitor. It also has to run in several environments (dev, test, prod) that differ in small ways, such as replica counts, resources, image tags or hostnames. Copying the manifests for every environment and editing them by hand quickly leads to drift and mistakes.

**Kustomize** and **Helm** are the two standard tools for packaging Kubernetes manifests and managing these differences. Both work with `oc`, and both are supported by Argo CD (OpenShift GitOps).

| | Kustomize | Helm |
| --- | --- | --- |
| **Approach** | Patches plain YAML: a *base* plus per-environment *overlays* | Templates: YAML with placeholders filled from *values* |
| **What you write** | Valid Kubernetes YAML, no templating language | Go templates (`{{ .Values.replicaCount }}`) |
| **Tooling** | Built into `oc` and `kubectl` (`oc apply -k`) | Separate `helm` CLI |
| **Release tracking** | None. It renders YAML, and something else applies it. | Tracks *releases* in the cluster, with history and `helm rollback` |
| **Sharing** | Point at a Git directory | Package a *chart* and publish it to a Helm or OCI registry |
| **Best for** | Your own apps with a few environment differences | Reusable, configurable software shared with other teams or the community |

!!! tip "Which one should I use?"
    Many teams use **both**: Helm to install third-party software (databases, monitoring stacks) and Kustomize for their own applications. In GitOps, Argo CD renders either one from Git, so you don't run `helm install` or `oc apply` by hand in production.

## Kustomize

Kustomize starts from a **base**, the parts that are the same everywhere, and applies **overlays** that add or change things for one environment. Everything is plain YAML, and the output is plain YAML.

```text
sample-app/kustomize/
├── base/                     # shared by every environment
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── components/
│   └── openshift-route/      # optional piece, reused by overlays
└── overlays/
    ├── dev/kustomization.yaml    # 1 replica, dev greeting
    └── prod/                     # 3 replicas, more memory
        ├── kustomization.yaml
        └── resources-patch.yaml
```

```yaml title="overlays/prod/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base                      # start from the base
components:
  - ../../components/openshift-route
labels:
  - pairs:
      environment: prod             # added to every resource
    includeSelectors: false
replicas:
  - name: greeting
    count: 3                        # override replicas
configMapGenerator:
  - name: greeting-config           # generated ConfigMap with a content hash in its name
    literals:
      - GREETING=Welcome to production
images:
  - name: ghcr.io/ibm-cloud-architecture/cloud-native-bootcamp/greeting
    newTag: v1.0.0                  # pin or promote an image tag
patches:
  - path: resources-patch.yaml      # strategic merge patch
```

Common transformations:

- `resources`, `components`: what to include
- `namespace`, `namePrefix`, `nameSuffix`, `labels`, `annotations`: applied to every resource
- `images`: change image names, tags or digests without editing the Deployment
- `replicas`: change replica counts
- `configMapGenerator`, `secretGenerator`: build ConfigMaps and Secrets from literals or files. The generated name includes a hash of the content, so changing a value rolls the Deployment automatically.
- `patches`: strategic merge patches or JSON 6902 patches for anything else

=== "OpenShift"

    ``` Bash title="Render an overlay without applying it"
    oc kustomize sample-app/kustomize/overlays/prod
    ```

    ``` Bash title="See what would change in the cluster"
    oc diff -k sample-app/kustomize/overlays/prod
    ```

    ``` Bash title="Apply an overlay"
    oc apply -k sample-app/kustomize/overlays/prod
    ```

=== "Kubernetes"

    ``` Bash title="Render an overlay without applying it"
    kubectl kustomize sample-app/kustomize/overlays/prod
    ```

    ``` Bash title="See what would change in the cluster"
    kubectl diff -k sample-app/kustomize/overlays/prod
    ```

    ``` Bash title="Apply an overlay"
    kubectl apply -k sample-app/kustomize/overlays/prod
    ```

## Helm

Helm packages an application as a **chart**: templates plus a `values.yaml` file of defaults. Installing a chart creates a **release**, and Helm records every revision in the cluster, so you can see the history and roll back.

```text
sample-app/helm/greeting/
├── Chart.yaml            # name, version, appVersion
├── values.yaml           # defaults
├── values-prod.yaml      # overrides for production
└── templates/
    ├── _helpers.tpl      # reusable snippets (labels)
    ├── deployment.yaml
    ├── service.yaml
    ├── route.yaml        # only rendered on OpenShift
    ├── servicemonitor.yaml
    ├── NOTES.txt         # printed after install
    └── tests/test-connection.yaml
```

```yaml title="templates/deployment.yaml (excerpt)"
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    spec:
      containers:
        - name: greeting
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          env:
            - name: GREETING
              value: {{ .Values.greeting | quote }}
```

Values are merged in order, and later sources win: the chart's `values.yaml`, then each `-f file.yaml`, then each `--set key=value`.

``` Bash title="Common Helm commands"
helm lint ./greeting                                   # check the chart
helm template demo ./greeting -f values-prod.yaml      # render locally, no cluster changes
helm install greeting ./greeting --wait                # create a release
helm upgrade greeting ./greeting --set replicaCount=2  # change it (new revision)
helm upgrade --install greeting ./greeting -f values-prod.yaml   # idempotent install-or-upgrade
helm history greeting                                  # list revisions
helm rollback greeting 1                               # go back to revision 1 (as a new revision)
helm test greeting                                     # run the chart's test pods
helm uninstall greeting
```

!!! info "Helm 4"
    Helm 4 is the current major version. Most commands are unchanged from Helm 3, but a few defaults differ: installs use Kubernetes **server-side apply**, `--atomic` is now `--rollback-on-failure`, and `--wait` accepts a strategy (`--wait=watcher`). Charts built for Helm 3 (`apiVersion: v2`) keep working.

Charts are shared through registries. Modern registries such as Quay.io, GHCR and the OpenShift internal registry store charts as **OCI artifacts**, next to container images:

```bash
helm package ./greeting                                   # creates greeting-0.1.0.tgz
helm push greeting-0.1.0.tgz oci://quay.io/<your-user>/charts
helm install greeting oci://quay.io/<your-user>/charts/greeting --version 0.1.0
```

## Packaging and GitOps

In GitOps, you commit the Kustomize overlay or Helm values to Git, and Argo CD renders and applies them. An Argo CD Application can point at either:

```yaml title="Kustomize overlay"
source:
  repoURL: https://github.com/<you>/cloud-native-bootcamp.git
  targetRevision: main
  path: sample-app/kustomize/overlays/prod
```

```yaml title="Helm chart with values"
source:
  repoURL: https://github.com/<you>/cloud-native-bootcamp.git
  targetRevision: main
  path: sample-app/helm/greeting
  helm:
    valueFiles:
      - values-prod.yaml
```

Promoting a new version to an environment is then a Git change, such as updating `newTag` in an overlay or `image.tag` in a values file.

## Resources

=== "OpenShift"

    [Using Helm on OpenShift :fontawesome-solid-box:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/building_applications/working-with-helm-charts){ .md-button target="_blank"}

=== "Kubernetes"

    [Kustomize :fontawesome-solid-box:](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/){ .md-button target="_blank"}

    [Helm documentation :fontawesome-solid-box:](https://helm.sh/docs/){ .md-button target="_blank"}

## Activities

| Lab | Description |
| --- | ----------- |
| [Lab 12 - Helm & Kustomize](../../labs/kubernetes/lab12/index.md) | Deploy one app to dev and prod with Kustomize, then manage it as a Helm release |
