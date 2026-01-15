# Tekton Lab - OpenShift Pipelines

## Overview

In this lab, you will learn how to use **OpenShift Pipelines**, which is based on Tekton and provides a cloud-native, Kubernetes-native CI/CD solution. OpenShift Pipelines is installed via the Red Hat OpenShift Pipelines Operator from OperatorHub.

## Prerequisites

- Access to an OpenShift cluster (4.10 or later recommended)
- `oc` CLI installed and configured
- Cluster admin privileges (for installing the operator) or the operator already installed

## Setup

### Install the OpenShift Pipelines Operator

The OpenShift Pipelines Operator can be installed from the OperatorHub in the OpenShift web console or via the CLI.

#### Option 1: Install via Web Console (Recommended)

1. Log in to the OpenShift web console as a cluster administrator
2. Navigate to **Operators** → **OperatorHub**
3. Search for **Red Hat OpenShift Pipelines**
4. Click on the operator and then click **Install**
5. Accept the default settings and click **Install**
6. Wait for the operator to install (status shows "Succeeded")

#### Option 2: Install via CLI

Create a subscription for the OpenShift Pipelines Operator:

```bash
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-pipelines-operator
  namespace: openshift-operators
spec:
  channel: latest
  name: openshift-pipelines-operator-rh
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

Wait for the operator to be ready:

```bash
oc get csv -n openshift-operators -w
```

You should see `openshift-pipelines-operator-rh` with phase `Succeeded`.

### Verify Installation

Once installed, verify that the Tekton components are running:

```bash
oc get pods -n openshift-pipelines
```

You should see pods for the pipelines controller, webhook, and other components in `Running` state.

### Install the Tekton CLI (tkn)

The `tkn` CLI is used to interact with Tekton/OpenShift Pipelines resources.

**macOS:**

```bash
brew install tektoncd-cli
```

**Linux:**

```bash
# Download the latest release
curl -LO https://github.com/tektoncd/cli/releases/latest/download/tkn_Linux_x86_64.tar.gz
tar xvzf tkn_Linux_x86_64.tar.gz
sudo mv tkn /usr/local/bin/
```

**Verify installation:**

```bash
tkn version
```

## Create a Project

Create a new OpenShift project for this lab:

```bash
export NAMESPACE=tekton-demo
oc new-project $NAMESPACE
```

> **Note:** OpenShift Pipelines automatically creates a `pipeline` ServiceAccount in each namespace with the necessary permissions.

## Understanding Tekton Concepts

Before diving into the lab, let's understand the key Tekton concepts:

- **Task** - A collection of steps that run sequentially in a pod
- **TaskRun** - An execution of a Task
- **Pipeline** - A collection of Tasks that can run in sequence or parallel
- **PipelineRun** - An execution of a Pipeline
- **Workspace** - A shared storage volume for Tasks in a Pipeline

## Part 1: Creating Tasks

### Create a Simple Task

A Task defines a series of steps that run in order. Create a file called `task-hello.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: hello
spec:
  params:
    - name: message
      type: string
      default: "Hello from Tekton!"
  steps:
    - name: say-hello
      image: registry.access.redhat.com/ubi8/ubi-minimal:latest
      script: |
        #!/bin/bash
        echo "$(params.message)"
```

Apply the Task:

```bash
oc apply -f task-hello.yaml -n $NAMESPACE
```

List Tasks using the Tekton CLI:

```bash
tkn task ls -n $NAMESPACE
```

### Run the Task

You can run a Task using the `tkn` CLI:

```bash
tkn task start hello --showlog -n $NAMESPACE
```

Or create a TaskRun YAML. Create `taskrun-hello.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: hello-run-
spec:
  taskRef:
    name: hello
  params:
    - name: message
      value: "Hello from OpenShift Pipelines!"
```

Apply it:

```bash
oc create -f taskrun-hello.yaml -n $NAMESPACE
```

Check the TaskRun status:

```bash
tkn taskrun ls -n $NAMESPACE
tkn taskrun logs --last -n $NAMESPACE
```

### Create a Build Task

Now let's create a more practical Task that clones a Git repository and builds a container image. We'll use the built-in ClusterTasks provided by OpenShift Pipelines.

List available ClusterTasks:

```bash
tkn clustertask ls
```

You should see tasks like `git-clone`, `buildah`, `openshift-client`, and others.

## Part 2: Creating a Pipeline

### Create a CI/CD Pipeline

Create a Pipeline that:

1. Clones a Git repository
2. Builds a container image
3. Deploys to OpenShift

Create `pipeline.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: build-and-deploy
spec:
  params:
    - name: git-url
      type: string
      description: The Git repository URL
      default: https://github.com/openshift/nodejs-ex.git
    - name: git-revision
      type: string
      description: The Git revision to build
      default: master
    - name: image-name
      type: string
      description: The name of the image to build
    - name: deployment-name
      type: string
      description: The name of the deployment
      default: nodejs-app
  workspaces:
    - name: shared-workspace
      description: Workspace for sharing data between tasks
  tasks:
    - name: fetch-source
      taskRef:
        name: git-clone
        kind: ClusterTask
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: url
          value: $(params.git-url)
        - name: revision
          value: $(params.git-revision)
        - name: deleteExisting
          value: "true"

    - name: build-image
      taskRef:
        name: buildah
        kind: ClusterTask
      runAfter:
        - fetch-source
      workspaces:
        - name: source
          workspace: shared-workspace
      params:
        - name: IMAGE
          value: $(params.image-name)
        - name: TLSVERIFY
          value: "false"

    - name: deploy
      taskRef:
        name: openshift-client
        kind: ClusterTask
      runAfter:
        - build-image
      params:
        - name: SCRIPT
          value: |
            oc new-app $(params.image-name) --name=$(params.deployment-name) || \
            oc set image deployment/$(params.deployment-name) $(params.deployment-name)=$(params.image-name)
            oc rollout status deployment/$(params.deployment-name)
```

Apply the Pipeline:

```bash
oc apply -f pipeline.yaml -n $NAMESPACE
```

List Pipelines:

```bash
tkn pipeline ls -n $NAMESPACE
```

### Create a PersistentVolumeClaim for the Workspace

Pipelines need storage to share data between tasks. Create `pvc.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pipeline-workspace
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

Apply the PVC:

```bash
oc apply -f pvc.yaml -n $NAMESPACE
```

### Run the Pipeline

Set up the image URL using the internal OpenShift registry:

```bash
export IMAGE_URL=image-registry.openshift-image-registry.svc:5000/$NAMESPACE/nodejs-app
```

Run the Pipeline using the `tkn` CLI:

```bash
tkn pipeline start build-and-deploy \
  -p git-url=https://github.com/openshift/nodejs-ex.git \
  -p git-revision=master \
  -p image-name=$IMAGE_URL \
  -p deployment-name=nodejs-app \
  -w name=shared-workspace,claimName=pipeline-workspace \
  --showlog \
  -n $NAMESPACE
```

Or create a PipelineRun YAML. Create `pipelinerun.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: build-and-deploy-run-
spec:
  pipelineRef:
    name: build-and-deploy
  params:
    - name: git-url
      value: https://github.com/openshift/nodejs-ex.git
    - name: git-revision
      value: master
    - name: image-name
      value: image-registry.openshift-image-registry.svc:5000/tekton-demo/nodejs-app
    - name: deployment-name
      value: nodejs-app
  workspaces:
    - name: shared-workspace
      persistentVolumeClaim:
        claimName: pipeline-workspace
```

Apply it:

```bash
oc create -f pipelinerun.yaml -n $NAMESPACE
```

### Monitor the Pipeline

Watch the PipelineRun progress:

```bash
tkn pipelinerun ls -n $NAMESPACE
tkn pipelinerun logs --last -f -n $NAMESPACE
```

You can also view the pipeline in the OpenShift web console under **Pipelines** → **Pipelines**.

## Part 3: Using the OpenShift Web Console

OpenShift provides a visual interface for managing Pipelines.

### View Pipelines in the Console

1. Navigate to **Pipelines** → **Pipelines** in the left menu
2. Select your project (`tekton-demo`)
3. You should see your `build-and-deploy` Pipeline
4. Click on it to see details and run history

### Start a Pipeline from the Console

1. Click on the Pipeline name
2. Click **Actions** → **Start**
3. Fill in the parameters
4. Select the workspace (PVC)
5. Click **Start**

### View PipelineRuns

1. Navigate to **Pipelines** → **PipelineRuns**
2. Click on a PipelineRun to see:
   - Task status
   - Logs for each step
   - Duration and timing

## Part 4: Expose the Application

After the Pipeline completes successfully, expose the application:

```bash
oc expose deployment nodejs-app --port=8080 -n $NAMESPACE
oc expose service nodejs-app -n $NAMESPACE
```

Get the application URL:

```bash
export APP_URL=$(oc get route nodejs-app -o jsonpath='{.spec.host}' -n $NAMESPACE)
echo "Application URL: http://$APP_URL"
```

Test the application:

```bash
curl http://$APP_URL
```

Or open the URL in a browser.

## Part 5: Triggers (Optional)

OpenShift Pipelines supports Triggers to automatically start Pipelines based on events like Git webhooks.

### Create an EventListener

Create `eventlistener.yaml`:

```yaml
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: build-deploy-listener
spec:
  serviceAccountName: pipeline
  triggers:
    - name: github-push
      bindings:
        - ref: github-push-binding
      template:
        ref: build-deploy-template
---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: github-push-binding
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
  name: build-deploy-template
spec:
  params:
    - name: git-url
    - name: git-revision
  resourcetemplates:
    - apiVersion: tekton.dev/v1
      kind: PipelineRun
      metadata:
        generateName: build-and-deploy-triggered-
      spec:
        pipelineRef:
          name: build-and-deploy
        params:
          - name: git-url
            value: $(tt.params.git-url)
          - name: git-revision
            value: $(tt.params.git-revision)
          - name: image-name
            value: image-registry.openshift-image-registry.svc:5000/tekton-demo/nodejs-app
          - name: deployment-name
            value: nodejs-app
        workspaces:
          - name: shared-workspace
            persistentVolumeClaim:
              claimName: pipeline-workspace
```

Apply the Trigger resources:

```bash
oc apply -f eventlistener.yaml -n $NAMESPACE
```

Expose the EventListener:

```bash
oc expose svc el-build-deploy-listener -n $NAMESPACE
```

Get the webhook URL:

```bash
echo "Webhook URL: http://$(oc get route el-build-deploy-listener -o jsonpath='{.spec.host}' -n $NAMESPACE)"
```

You can configure this URL in your Git repository's webhook settings to trigger the Pipeline on push events.

## Cleanup

To clean up all resources created in this lab:

```bash
# Delete all pipeline resources
oc delete pipelinerun --all -n $NAMESPACE
oc delete taskrun --all -n $NAMESPACE
oc delete pipeline --all -n $NAMESPACE
oc delete task --all -n $NAMESPACE
oc delete pvc pipeline-workspace -n $NAMESPACE

# Delete the application
oc delete deployment,svc,route nodejs-app -n $NAMESPACE

# Delete the project (optional)
oc delete project $NAMESPACE
```

## Summary

In this lab, you learned how to:

- Install and configure OpenShift Pipelines using the Operator
- Create Tasks and TaskRuns
- Create Pipelines that clone, build, and deploy applications
- Use Workspaces to share data between Tasks
- Monitor Pipelines using the `tkn` CLI and OpenShift web console
- Set up Triggers for automated Pipeline execution

## Additional Resources

- [OpenShift Pipelines Documentation](https://docs.openshift.com/pipelines/latest/about/understanding-openshift-pipelines.html)
- [Tekton Documentation](https://tekton.dev/docs/)
- [Tekton Hub](https://hub.tekton.dev/) - Reusable Tasks and Pipelines
- [OpenShift Pipelines Tutorial](https://github.com/openshift/pipelines-tutorial)
