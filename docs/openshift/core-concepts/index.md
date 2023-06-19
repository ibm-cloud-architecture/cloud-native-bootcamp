# Kubernetes API Primitives

Kubernetes API primitive, also known as Kubernetes objects, are the basic building blocks of any application running in Kubernetes

Examples:

- Pod
- Node
- Service
- ServiceAccount

Two primary members

- Spec, desired state
- Status, current state

## Resources

=== "OpenShift"

     [Pods :fontawesome-solid-globe:](https://docs.openshift.com/container-platform/4.13/nodes/pods/nodes-pods-using.html){ .md-button target="_blank"}

     [Nodes :fontawesome-solid-globe:](https://docs.openshift.com/container-platform/4.13/nodes/nodes/nodes-nodes-viewing.html){ .md-button target="_blank"}

=== "Kubernetes"

     [Objects :fontawesome-solid-globe:](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/){ .md-button target="_blank"}
     
     [Kube Basics :fontawesome-solid-globe:](https://kubernetes.io/docs/tutorials/kubernetes-basics/){ .md-button target="_blank"}


## References

=== "OpenShift"

    ``` Bash title="List API-Resources"
    oc api-resources
    ```

=== "Kubernetes"

    ``` Bash title="List API-Resources"
    kubectl api-resources
    ```