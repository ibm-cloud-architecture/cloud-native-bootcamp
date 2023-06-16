# Projects/Namespaces

Namespaces are intended for use in environments with many users spread across multiple teams, or projects.

Namespaces provide a scope for names. Names of resources need to be unique within a namespace, but not across namespaces.

Namespaces are a way to divide cluster resources between multiple users (via resource quota).

It is not necessary to use multiple namespaces just to separate slightly different resources, such as different versions of the same software: use labels to distinguish resources within the same namespace. In practice namespaces are used to deploy different versions based on stages of the CICD pipeline (dev, test, stage, prod)

## Resources

=== "OpenShift"

    [Working with Projects :fontawesome-solid-globe:](https://docs.openshift.com/container-platform/4.13/applications/projects/working-with-projects.html){ .md-button }
    [Creating Projects :fontawesome-solid-globe:](https://docs.openshift.com/container-platform/4.13/cli_reference/openshift_cli/getting-started-cli.html#creating-a-project){ .md-button }
    [Configure Project Creation :fontawesome-solid-globe:](https://docs.openshift.com/container-platform/4.13/applications/projects/configuring-project-creation.html){ .md-button }

=== "Kubernetes"

    [Namespaces :fontawesome-solid-globe:](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/){ .md-button }

## References

```yaml title="Namespace YAML"
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

```yaml title="Pod YAML specifiying Namespace"
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

    ``` Bash title="Create a new namespace called bar"
    kubectl create ns dev
    ```

    ``` Bash title="Setting Namespace in Context"
    kubectl config set-context --current --namespace=dev
    ```
