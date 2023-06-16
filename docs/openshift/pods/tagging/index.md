# Labels, Selectors, and Annotations

Labels are key/value pairs that are attached to objects, such as pods. Labels are intended to be used to specify identifying attributes of objects that are meaningful and relevant to users, but do not directly imply semantics to the core system. Labels can be used to organize and to select subsets of objects. Labels can be attached to objects at creation time and subsequently added and modified at any time. Each object can have a set of key/value labels defined. Each Key must be unique for a given object.

You can use Kubernetes annotations to attach arbitrary non-identifying metadata to objects. Clients such as tools and libraries can retrieve this metadata.

You can use either labels or annotations to attach metadata to Kubernetes objects. Labels can be used to select objects and to find collections of objects that satisfy certain conditions. In contrast, annotations are not used to identify and select objects. The metadata in an annotation can be small or large, structured or unstructured, and can include characters not permitted by labels.

## Resources

=== "OpenShift"

=== "Kubernetes"


**OpenShift**
- [CLI Label Commands](https://docs.openshift.com/enterprise/3.0/cli_reference/basic_cli_operations.html#application-modification-cli-operations)

**IKS**
- [Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
- [Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)


## References

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
  labels:
    app: foo
    tier: frontend
    env: dev
  annotations:
    imageregistry: "https://hub.docker.com/"
    gitrepo: "https://github.com/csantanapr/knative"
spec:
  containers:
  - name: app
    image: bitnami/nginx
```

=== "OpenShift"

    ** Change Labels on Objects **
    ```
    oc label pod my-pod boot=camp
    ```
    **Getting Pods based on their labels.**
    ```
    oc get pods --show-labels
    ```
    ```
    oc get pods -L tier,env
    ```
    ```
    oc get pods -l app
    ```
    ```
    oc get pods -l tier=frontend
    ```
    ```
    oc get pods -l 'env=dev,tier=frontend'
    ```
    ```
    oc get pods -l 'env in (dev, test)'
    ```
    ```
    oc get pods -l 'tier!=backend'
    ```
    ```
    oc get pods -l 'env,env notin (prod)'
    ```
    **Delete the Pod.**
    ```
    oc delete pod my-pod
    ```

=== "Kubernetes"

    ** Change Labels on Objects **
    ```
    kubectl label pod my-pod boot=camp
    ```
    **Getting Pods based on their labels.**
    ```
    kubectl get pods --show-labels
    ```
    ```
    kubectl get pods -L tier,env
    ```
    ```
    kubectl get pods -l app
    ```
    ```
    kubectl get pods -l tier=frontend
    ```
    ```
    kubectl get pods -l 'env=dev,tier=frontend'
    ```
    ```
    kubectl get pods -l 'env in (dev, test)'
    ```
    ```
    kubectl get pods -l 'tier!=backend'
    ```
    ```
    kubectl get pods -l 'env,env notin (prod)'
    ```
    **Delete the Pod.**
    ```
    kubectl delete pod my-pod
    ```