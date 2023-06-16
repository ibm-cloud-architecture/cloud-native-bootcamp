# Deployments

A Deployment provides declarative updates for Pods and ReplicaSets.

You describe a desired state in a Deployment, and the Deployment Controller changes the actual state to the desired state at a controlled rate. You can define Deployments to create new ReplicaSets, or to remove existing Deployments and adopt all their resources with new Deployments.

The following are typical use cases for Deployments:
- Create a Deployment to rollout a ReplicaSet. The ReplicaSet creates Pods in the background. Check the status of the rollout to see if it succeeds or not.
- Declare the new state of the Pods by updating the PodTemplateSpec of the Deployment. A new ReplicaSet is created and the Deployment manages moving the Pods from the old ReplicaSet to the new one at a controlled rate. Each new ReplicaSet updates the revision of the Deployment.
- Rollback to an earlier Deployment revision if the current state of the Deployment is not stable. Each rollback updates the revision of the Deployment.
- Scale up the Deployment to facilitate more load.
- Pause the Deployment to apply multiple fixes to its PodTemplateSpec and then resume it to start a new rollout.
- Use the status of the Deployment as an indicator that a rollout has stuck.
- Clean up older ReplicaSets that you don’t need anymore.


## Resources

**OpenShift**

- [Deployments](https://docs.openshift.com/container-platform/4.13/applications/deployments/what-deployments-are.html){:target="_blank"}
- [Managing Deployment Processes](https://docs.openshift.com/container-platform/4.13/applications/deployments/managing-deployment-processes.html){:target="_blank"}
- [DeploymentConfig Strategies](https://docs.openshift.com/container-platform/4.13/applications/deployments/deployment-strategies.html){:target="_blank"}
- [Route Based Deployment Strategies](https://docs.openshift.com/container-platform/4.13/applications/deployments/route-based-deployment-strategies.html){:target="_blank"}

**IKS**

- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/){:target="_blank"}
- [Scaling Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#scaling-a-deployment){:target="_blank"}

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

=== "Openshift"

    ``` Bash title="Create a Deployment"
    oc apply -f deployment.yaml
    ```

    ``` Bash title="Get Deployment"
    oc get deployment my-deployment
    ```

    ``` Bash title="Get Deployment's Description"
    oc describe deployment my-deployment
    ```

    ``` Bash title="Edit Deployment"
    oc edit deployment my-deployment
    ```

    ``` Bash title="Scale Deployment"
    oc scale deployment/my-deployment --replicas=3
    ```

    ``` Bash title="Delete Deployment"
    oc delete deployment my-deployment
    ```

=== "Kubernetes"

    ``` Bash title="Create a Deployment"
    kubectl apply -f deployment.yaml
    ```

    ``` Bash title="Get Deployment"
    kubectl get deployment my-deployment
    ```

    ``` Bash title="Get Deployment's Description"
    kubectl describe deployment my-deployment
    ```

    ``` Bash title="Edit Deployment"
    kubectl edit deployment my-deployment
    ```

    ``` Bash title="Scale Deployment"
    kubectl scale deployment/my-deployment --replicas=3
    ```

    ``` Bash title="Delete Deployment"
    kubectl delete deployment my-deployment
    ```