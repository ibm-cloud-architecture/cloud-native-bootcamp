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
- [Pods](https://docs.openshift.com/container-platform/4.3/nodes/pods/nodes-pods-using.html)
- [Nodes](https://docs.openshift.com/container-platform/4.3/nodes/nodes/nodes-nodes-viewing.html)

**IKS**
- [Objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/)
- [Kube Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)


## References

=== "OpenShift"

    ``` Bash title="List API-Resources"
    oc api-resources
    ```

=== "Kubernetes"

    ``` Bash title="List API-Resources"
    kubectl api-resources
    ```