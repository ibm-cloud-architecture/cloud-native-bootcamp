# Rolling Updates and Rollbacks

**Updating a Deployment**
A Deployment’s rollout is triggered if and only if the Deployment’s Pod template (that is, .spec.template) is changed, for example if the labels or container images of the template are updated. Other updates, such as scaling the Deployment, do not trigger a rollout.

Each time a new Deployment is observed by the Deployment controller, a ReplicaSet is created to bring up the desired Pods. If the Deployment is updated, the existing ReplicaSet that controls Pods whose labels match .spec.selector but whose template does not match .spec.template are scaled down. Eventually, the new ReplicaSet is scaled to .spec.replicas and all old ReplicaSets is scaled to 0.

**Label selector updates**
It is generally discouraged to make label selector updates and it is suggested to plan your selectors up front. In any case, if you need to perform a label selector update, exercise great caution and make sure you have grasped all of the implications.

**Rolling Back a Deployment**
Sometimes, you may want to rollback a Deployment; for example, when the Deployment is not stable, such as crash looping. By default, all of the Deployment’s rollout history is kept in the system so that you can rollback anytime you want (you can change that by modifying revision history limit).

A Deployment’s revision is created when a Deployment’s rollout is triggered. This means that the new revision is created if and only if the Deployment’s Pod template (.spec.template) is changed, for example if you update the labels or container images of the template. Other updates, such as scaling the Deployment, do not create a Deployment revision, so that you can facilitate simultaneous manual- or auto-scaling. This means that when you roll back to an earlier revision, only the Deployment’s Pod template part is rolled back.

## Resources

=== "OpenShift"

    [Rollouts :fontawesome-solid-globe:](https://docs.openshift.com/container-platform/4.13/applications/deployments/what-deployments-are.html#delpoymentconfigs-specific-features_what-deployments-are){ .md-button target="_blank"}

    [Rolling Back :fontawesome-solid-globe:](https://docs.openshift.com/container-platform/4.13/applications/deployments/managing-deployment-processes.html#deployments-rolling-back_deployment-operations){ .md-button target="_blank"}

=== "Kubernetes"

    [Updating a Deployment :fontawesome-solid-globe:](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment){ .md-button target="_blank"}

    [Rolling Back a Deployment :fontawesome-solid-globe:](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-back-a-deployment){ .md-button target="_blank"}


## References

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: bitnami/nginx:1.16.0
        ports:
        - containerPort: 8080
```

=== "OpenShift"

    ``` Bash title="Get Deployments"
    oc get deployments
    ```

    ``` Bash title="Sets new image for Deployment"
    oc set image deployment/my-deployment nginx=bitnami/nginx:1.16.1 --record
    ```

    ``` Bash title="Check the status of a rollout"
    oc rollout status deployment my-deployment
    ```

    ``` Bash title="Get Replicasets"
    oc get rs
    ```

    ``` Bash title="Get Deployment Description"
    oc describe deployment my-deployment
    ```

    ``` Bash title="Get Rollout History"
    oc rollout history deployment my-deployment
    ```

    ``` Bash title="Undo Rollout"
    oc rollback my-deployment
    ```

    ``` Bash title="Delete Deployment"
    oc delete deployment my-deployment
    ```

=== "Kubernetes"

    ``` Bash title="Create a Deployment"
    kubectl apply -f deployment.yaml
    ```

    ``` Bash title="Create a new namespace called bar"
    kubectl create ns dev
    ```

    ``` Bash title="Setting Namespace in Context"
    kubectl config set-context --current --namespace=dev
    ```