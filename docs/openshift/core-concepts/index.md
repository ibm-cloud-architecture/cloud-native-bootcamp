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

     [Pods :fontawesome-solid-globe:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/nodes/working-with-pods#nodes-pods-using-pp){ .md-button target="_blank"}

     [Nodes :fontawesome-solid-globe:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/nodes/working-with-nodes#nodes-nodes-viewing){ .md-button target="_blank"}

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