# Tekton Lab - OpenShift Pipelines

<span class="lab-badge">60 min</span> <span class="lab-badge">Intermediate</span>

In this lab you'll use **Red Hat OpenShift Pipelines**, Red Hat's supported distribution of [Tekton](https://tekton.dev/), to build a continuous integration pipeline. The pipeline clones the bootcamp's sample app from Git, builds a container image, pushes it to OpenShift's internal registry, and deploys it.

## Prerequisites

- An OpenShift 4.16+ cluster with the **Red Hat OpenShift Pipelines** operator installed. If it isn't installed and you're a cluster administrator, see [Install the operator](#install-the-operator). OpenShift Local and the Developer Sandbox can both run this lab.
- The `oc` CLI, logged in to the cluster.
- The `tkn` CLI:

    === "macOS"

        ```bash
        brew install tektoncd-cli
        ```

    === "Linux"

        Download the latest `tkn` archive for your architecture from the [Tekton CLI releases](https://github.com/tektoncd/cli/releases/latest), extract it, and move `tkn` onto your `PATH`. You can also download `tkn` from your cluster's web console, under the **?** menu > **Command Line Tools**.

    === "Windows"

        ```powershell
        winget install --id TektonCD.Cli
        ```

    Check it works with `tkn version`.

### Install the operator

Skip this section if OpenShift Pipelines is already installed. Check with `oc get csv -n openshift-operators | grep pipelines`.

=== "Web console"

    1. Log in to the web console as a cluster administrator.
    2. Go to **Operators > OperatorHub** (**Ecosystem > Software Catalog** on OpenShift 4.20 and later).
    3. Search for **Red Hat OpenShift Pipelines**, then click **Install** and accept the defaults.
    4. Wait until the operator status shows **Succeeded**.

=== "CLI"

    ```bash
    oc apply -f - <<'EOF'
    apiVersion: operators.coreos.com/v1alpha1
    kind: Subscription
    metadata:
      name: openshift-pipelines-operator-rh
      namespace: openshift-operators
    spec:
      channel: latest
      name: openshift-pipelines-operator-rh
      source: redhat-operators
      sourceNamespace: openshift-marketplace
    EOF
    ```

    Wait for the operator, then for the Tekton components it installs:

    ```bash
    oc get csv -n openshift-operators -w      # wait for PHASE = Succeeded, then Ctrl+C
    oc get pods -n openshift-pipelines
    ```

## Tekton concepts

| Resource | What it is |
| --- | --- |
| **Step** | A container that runs one command or script |
| **Task** | An ordered list of steps. Each Task run is one pod. |
| **Pipeline** | A graph of Tasks that run in sequence or in parallel |
| **TaskRun / PipelineRun** | One execution of a Task or Pipeline, with its parameter values, workspaces and logs |
| **Workspace** | Storage shared between Tasks, for example the cloned source code |
| **Resolver** | Fetches Task and Pipeline definitions from the cluster, a Git repo, a bundle or Artifact Hub |

## Setup

```bash
oc new-project tekton-lab
```

OpenShift Pipelines automatically creates a `pipeline` ServiceAccount in every project. PipelineRuns use it, and it has permission to push to the project's image streams and to create Deployments.

## Part 1: Your first Task

1. Save this Task as `hello-task.yaml`:

    ```yaml title="hello-task.yaml"
    apiVersion: tekton.dev/v1
    kind: Task
    metadata:
      name: hello
    spec:
      params:
        - name: name
          type: string
          default: Padawan
      steps:
        - name: say-hello
          image: registry.access.redhat.com/ubi9/ubi-minimal
          script: |
            #!/usr/bin/env bash
            echo "Hello, $(params.name)! Running in pod ${HOSTNAME}."
    ```

2. Create the Task and list the Tasks in your project:

    ```bash
    oc apply -f hello-task.yaml
    tkn task list
    ```

3. Run it with `tkn`, override the parameter, and stream the logs:

    ```bash
    tkn task start hello -p name=Jedi --showlog
    ```

    ```text title="Expected output"
    TaskRun started: hello-run-8xk2p
    Waiting for logs to be available...
    [say-hello] Hello, Jedi! Running in pod hello-run-8xk2p-pod.
    ```

4. `tkn` created a **TaskRun** object for you. List the TaskRuns, then look at the pod that ran the step:

    ```bash
    tkn taskrun list
    oc get pods
    ```

## Part 2: A build-and-deploy Pipeline

Instead of writing every Task yourself, reuse the Tasks that OpenShift Pipelines ships in the `openshift-pipelines` namespace. Reference them with the **cluster resolver**:

```bash
oc get tasks -n openshift-pipelines
```

This lab uses three of them:

| Task | Purpose | Key parameters |
| --- | --- | --- |
| `git-clone` | Clone a Git repository into a workspace | `URL`, `REVISION` |
| `buildah` | Build an image from a Containerfile and push it | `IMAGE`, `DOCKERFILE`, `CONTEXT` |
| `openshift-client` | Run `oc` commands | `SCRIPT` |

!!! note "Coming from ClusterTasks?"
    Older tutorials use `kind: ClusterTask` references. OpenShift Pipelines 1.17 removed ClusterTasks. Use `resolver: cluster`, as shown below.

1. Save this Pipeline as `pipeline.yaml`:

    ```yaml title="pipeline.yaml"
    apiVersion: tekton.dev/v1
    kind: Pipeline
    metadata:
      name: build-and-deploy
    spec:
      params:
        - name: git-url
          type: string
          default: https://github.com/ibm-cloud-architecture/cloud-native-bootcamp.git
        - name: git-revision
          type: string
          default: main
        - name: context-dir
          type: string
          description: Directory in the repo that contains the Containerfile
          default: sample-app/greeting
        - name: app-name
          type: string
          default: greeting
      workspaces:
        - name: source
      tasks:
        - name: fetch-source
          taskRef:
            resolver: cluster
            params:
              - { name: kind, value: task }
              - { name: name, value: git-clone }
              - { name: namespace, value: openshift-pipelines }
          params:
            - { name: URL, value: $(params.git-url) }
            - { name: REVISION, value: $(params.git-revision) }
          workspaces:
            - { name: output, workspace: source }

        - name: build-image
          runAfter: [fetch-source]
          taskRef:
            resolver: cluster
            params:
              - { name: kind, value: task }
              - { name: name, value: buildah }
              - { name: namespace, value: openshift-pipelines }
          params:
            - name: IMAGE
              value: image-registry.openshift-image-registry.svc:5000/$(context.pipelineRun.namespace)/$(params.app-name):latest
            - { name: CONTEXT, value: $(params.context-dir) }
            - { name: DOCKERFILE, value: $(params.context-dir)/Containerfile }
          workspaces:
            - { name: source, workspace: source }

        - name: deploy
          runAfter: [build-image]
          taskRef:
            resolver: cluster
            params:
              - { name: kind, value: task }
              - { name: name, value: openshift-client }
              - { name: namespace, value: openshift-pipelines }
          params:
            - name: SCRIPT
              value: |
                IMAGE="$(tasks.build-image.results.IMAGE_URL)@$(tasks.build-image.results.IMAGE_DIGEST)"
                oc get deployment $(params.app-name) || \
                  oc create deployment $(params.app-name) --image="${IMAGE}" --port=8080
                oc set image deployment/$(params.app-name) "*=${IMAGE}"
                oc rollout status deployment/$(params.app-name) --timeout=3m
                oc get service $(params.app-name) || oc expose deployment $(params.app-name) --port=8080
                oc get route $(params.app-name) || oc expose service $(params.app-name)
    ```

    A few things to notice:

    - `$(tasks.build-image.results.IMAGE_DIGEST)` passes a **result** from one Task to another. Deploying by digest guarantees that every build rolls out, even though the tag (`latest`) stays the same.
    - `$(context.pipelineRun.namespace)` resolves to the project the pipeline runs in.
    - The `deploy` script is idempotent: it creates the Deployment, Service and Route on the first run and only updates the image afterwards.

2. Create the Pipeline and look at it:

    ```bash
    oc apply -f pipeline.yaml
    tkn pipeline describe build-and-deploy
    ```

3. Start a run. The `source` workspace gets a new 1 GiB PersistentVolumeClaim for each run, created from a **volumeClaimTemplate**:

    === "tkn"

        ```bash
        cat > workspace-template.yaml <<'EOF'
        spec:
          accessModes: [ReadWriteOnce]
          resources:
            requests:
              storage: 1Gi
        EOF

        tkn pipeline start build-and-deploy \
          --use-param-defaults \
          --workspace name=source,volumeClaimTemplateFile=workspace-template.yaml \
          --showlog
        ```

    === "PipelineRun YAML"

        ```yaml title="pipelinerun.yaml"
        apiVersion: tekton.dev/v1
        kind: PipelineRun
        metadata:
          generateName: build-and-deploy-
        spec:
          pipelineRef:
            name: build-and-deploy
          workspaces:
            - name: source
              volumeClaimTemplate:
                spec:
                  accessModes: [ReadWriteOnce]
                  resources:
                    requests:
                      storage: 1Gi
        ```

        ```bash
        oc create -f pipelinerun.yaml
        tkn pipelinerun logs --last -f
        ```

4. When the run succeeds, call the app:

    ```bash
    tkn pipelinerun list
    curl "http://$(oc get route greeting -o jsonpath='{.spec.host}')/greeting?name=Tekton"
    ```

    ```json
    {"message":"Welcome to the Cloud Native Bootcamp!","name":"Tekton"}
    ```

## Part 3: The web console

1. In the web console, go to **Pipelines** and select the `tekton-lab` project.
2. Open `build-and-deploy` to see the Tasks as a graph, and open a PipelineRun to see each Task's logs and duration.
3. Start another run from **Actions > Start**. Choose **VolumeClaimTemplate** for the `source` workspace.
4. Change the `GREETING` environment variable of the Deployment (`oc set env deployment/greeting GREETING="Hello from the pipeline"`), run the pipeline again, and check whether your setting survives the redeploy. Why does it?

## Part 4 (optional): Build your own fork on every push

To run the pipeline automatically when code changes, it needs to be triggered by your Git provider.

1. Fork [the bootcamp repository](https://github.com/ibm-cloud-architecture/cloud-native-bootcamp) on GitHub.
2. Save these Triggers resources as `triggers.yaml`. They create an **EventListener** that receives GitHub push webhooks and starts a PipelineRun for the pushed commit:

    ```yaml title="triggers.yaml"
    apiVersion: triggers.tekton.dev/v1beta1
    kind: TriggerBinding
    metadata:
      name: github-push
    spec:
      params:
        - name: git-url
          value: $(body.repository.clone_url)
        - name: git-revision
          value: $(body.after)
    ---
    apiVersion: triggers.tekton.dev/v1beta1
    kind: TriggerTemplate
    metadata:
      name: build-and-deploy
    spec:
      params:
        - name: git-url
        - name: git-revision
      resourcetemplates:
        - apiVersion: tekton.dev/v1
          kind: PipelineRun
          metadata:
            generateName: build-and-deploy-
          spec:
            pipelineRef:
              name: build-and-deploy
            params:
              - { name: git-url, value: $(tt.params.git-url) }
              - { name: git-revision, value: $(tt.params.git-revision) }
            workspaces:
              - name: source
                volumeClaimTemplate:
                  spec:
                    accessModes: [ReadWriteOnce]
                    resources:
                      requests:
                        storage: 1Gi
    ---
    apiVersion: triggers.tekton.dev/v1beta1
    kind: EventListener
    metadata:
      name: github-listener
    spec:
      serviceAccountName: pipeline
      triggers:
        - name: github-push
          interceptors:
            - ref:
                name: github
              params:
                - name: eventTypes
                  value: ["push"]
          bindings:
            - ref: github-push
          template:
            ref: build-and-deploy
    ```

3. Create the resources and expose the EventListener:

    ```bash
    oc apply -f triggers.yaml
    oc expose service el-github-listener
    echo "http://$(oc get route el-github-listener -o jsonpath='{.spec.host}')"
    ```

4. In your fork, open **Settings > Webhooks > Add webhook**. Set **Payload URL** to the URL above and **Content type** to `application/json`, then save. Your cluster must be reachable from the internet, so this doesn't work with OpenShift Local.
5. Change the default message in `sample-app/greeting/main.go`, then commit and push. A new PipelineRun starts automatically: `tkn pipelinerun list`.

!!! tip "Pipelines as Code"
    OpenShift Pipelines also includes **[Pipelines as Code](https://pipelinesascode.com/)**. It keeps PipelineRun definitions in a `.tekton/` directory of your repository, runs them on pushes and pull requests, and reports the results back to GitHub or GitLab. It's the recommended way to run CI on OpenShift.

## Cleanup

```bash
oc delete project tekton-lab
```

## What you learned

- [x] Tekton building blocks: Steps, Tasks, Pipelines, runs, workspaces and results
- [x] Reusing the Tasks that ship with OpenShift Pipelines through the cluster resolver
- [x] Building and pushing images with buildah, and deploying by digest
- [x] Triggering pipelines from Git events

## Additional resources

- [Red Hat OpenShift Pipelines documentation](https://docs.redhat.com/en/documentation/red_hat_openshift_pipelines/)
- [Tekton documentation](https://tekton.dev/docs/)
- [Tekton Tasks on Artifact Hub](https://artifacthub.io/packages/search?kind=7)
- [OpenShift Pipelines tutorial](https://github.com/openshift/pipelines-tutorial)
