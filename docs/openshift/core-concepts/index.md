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

**OpenShift**

- [Pods](https://docs.openshift.com/container-platform/4.13/nodes/pods/nodes-pods-using.html){:target="_blank"}
- [Nodes](https://docs.openshift.com/container-platform/4.13/nodes/nodes/nodes-nodes-viewing.html){:target="_blank"}

**IKS**

- [Objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/){:target="_blank"}
- [Kube Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/){:target="_blank"}


## References

=== "OpenShift"

    ``` Bash title="List API-Resources"
    oc api-resources
    ```

=== "Kubernetes"

    ``` Bash title="List API-Resources"
    kubectl api-resources
    ```