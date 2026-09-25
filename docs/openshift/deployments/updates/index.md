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

    [Rollouts :fontawesome-solid-rotate-right:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/building_applications/deployments#what-deployments-are){ .md-button target="_blank"}

    [Rolling Back :fontawesome-solid-rotate-left:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/building_applications/deployments#deployment-operations){ .md-button target="_blank"}

=== "Kubernetes"

    [Updating a Deployment :fontawesome-solid-rotate-right:](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment){ .md-button target="_blank"}

    [Rolling Back a Deployment :fontawesome-solid-rotate-left:](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-back-a-deployment){ .md-button target="_blank"}

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
          image: quay.io/nginx/nginx-unprivileged:1.28
          ports:
            - containerPort: 8080
```

=== "OpenShift"

    ``` Bash title="Create a Deployment"
    oc apply -f deployment.yaml
    ```

    ``` Bash title="Get Deployments"
    oc get deployments
    ```

    ``` Bash title="Set a new image for the Deployment"
    oc set image deployment/my-deployment nginx=quay.io/nginx/nginx-unprivileged:1.29
    ```

    ``` Bash title="Record why you changed it (shown in the rollout history)"
    oc annotate deployment/my-deployment kubernetes.io/change-cause="Upgrade to nginx 1.29"
    ```

    ``` Bash title="Check the status of a rollout"
    oc rollout status deployment/my-deployment
    ```

    ``` Bash title="Get ReplicaSets"
    oc get rs
    ```

    ``` Bash title="Get Deployment Description"
    oc describe deployment my-deployment
    ```

    ``` Bash title="Get Rollout History"
    oc rollout history deployment/my-deployment
    ```

    ``` Bash title="Undo the last rollout"
    oc rollout undo deployment/my-deployment
    ```

    ``` Bash title="Roll back to a specific revision"
    oc rollout undo deployment/my-deployment --to-revision=2
    ```

    ``` Bash title="Pause and resume a rollout"
    oc rollout pause deployment/my-deployment
oc rollout resume deployment/my-deployment
    ```

    ``` Bash title="Restart all pods (for example, to pick up a changed Secret)"
    oc rollout restart deployment/my-deployment
    ```

    ``` Bash title="Delete Deployment"
    oc delete deployment my-deployment
    ```

=== "Kubernetes"

    ``` Bash title="Create a Deployment"
    kubectl apply -f deployment.yaml
    ```

    ``` Bash title="Get Deployments"
    kubectl get deployments
    ```

    ``` Bash title="Set a new image for the Deployment"
    kubectl set image deployment/my-deployment nginx=quay.io/nginx/nginx-unprivileged:1.29
    ```

    ``` Bash title="Record why you changed it (shown in the rollout history)"
    kubectl annotate deployment/my-deployment kubernetes.io/change-cause="Upgrade to nginx 1.29"
    ```

    ``` Bash title="Check the status of a rollout"
    kubectl rollout status deployment/my-deployment
    ```

    ``` Bash title="Get ReplicaSets"
    kubectl get rs
    ```

    ``` Bash title="Get Deployment Description"
    kubectl describe deployment my-deployment
    ```

    ``` Bash title="Get Rollout History"
    kubectl rollout history deployment/my-deployment
    ```

    ``` Bash title="Undo the last rollout"
    kubectl rollout undo deployment/my-deployment
    ```

    ``` Bash title="Roll back to a specific revision"
    kubectl rollout undo deployment/my-deployment --to-revision=2
    ```

    ``` Bash title="Pause and resume a rollout"
    kubectl rollout pause deployment/my-deployment
kubectl rollout resume deployment/my-deployment
    ```

    ``` Bash title="Restart all pods (for example, to pick up a changed Secret)"
    kubectl rollout restart deployment/my-deployment
    ```

    ``` Bash title="Delete Deployment"
    kubectl delete deployment my-deployment
    ```

## Activities

| Lab | Description |
| --- | ----------- |
| [Lab 7 - Rolling Updates](../../../labs/kubernetes/lab7/index.md) | Roll out a new version, then roll back a bad one |
