---
tags:
  - Kubernetes
  - OpenShift
---

# Projects/Namespaces

Namespaces are intended for use in environments with many users spread across multiple teams, or projects.

Namespaces provide a scope for names. Names of resources need to be unique within a namespace, but not across namespaces.

Namespaces are a way to divide cluster resources between multiple users (via resource quota).

It is not necessary to use multiple namespaces just to separate slightly different resources, such as different versions of the same software: use labels to distinguish resources within the same namespace. In practice namespaces are often used to separate teams, applications, or stages of the CI/CD pipeline (dev, test, stage, prod).

!!! info "Projects in OpenShift"
    An OpenShift **Project** is a Kubernetes namespace with extra metadata (display name, description) and default access control. When you run `oc new-project`, OpenShift creates the namespace and makes you its admin, even if you aren't allowed to create namespaces directly. Use `oc new-project` rather than `oc create namespace` on OpenShift.

## Resources

=== "OpenShift"

    [Working with Projects :fontawesome-solid-globe:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/building_applications/projects#working-with-projects){ .md-button target="_blank"}

    [Creating Projects :fontawesome-solid-globe:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/cli_tools/openshift-cli-oc#cli-getting-started){ .md-button target="_blank" }
    
    [Configure Project Creation :fontawesome-solid-globe:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/building_applications/projects#configuring-project-creation){ .md-button target="_blank"}

=== "Kubernetes"

    [Namespaces :fontawesome-solid-globe:](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/){ .md-button target="_blank"}

## References

```yaml title="Namespace YAML"
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

```yaml title="Pod YAML specifying Namespace"
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  namespace: dev
spec:
  containers:
    - name: myapp-container
      image: busybox
      command: ["sh", "-c", "echo Hello Kubernetes! && sleep 3600"]
```

=== "OpenShift"

    ``` Bash title="Getting all namespaces/projects"
    oc projects
    ```

    ``` Bash title="Create a new Project"
    oc new-project dev
    ```

    ``` Bash title="Viewing Current Project"
    oc project
    ```

    ``` Bash title="Setting Namespace in Context"
    oc project dev
    ```


    ``` Bash title="Viewing Project Status"
    oc status
    ```

=== "Kubernetes"

    ``` Bash title="Getting all namespaces"
    kubectl get namespaces
    ```

    ``` Bash title="Create a new namespace called dev"
    kubectl create ns dev
    ```

    ``` Bash title="Setting Namespace in Context"
    kubectl config set-context --current --namespace=dev
    ```
