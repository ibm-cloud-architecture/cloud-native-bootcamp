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

- [Deployments](https://docs.openshift.com/container-platform/4.3/applications/deployments/what-deployments-are.html)
- [Managing Deployment Processes](https://docs.openshift.com/container-platform/4.3/applications/deployments/managing-deployment-processes.html)
- [DeploymentConfig Strategies](https://docs.openshift.com/container-platform/4.3/applications/deployments/deployment-strategies.html)
- [Route Based Deployment Strategies](https://docs.openshift.com/container-platform/4.3/applications/deployments/route-based-deployment-strategies.html)

**IKS**

- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Scaling Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#scaling-a-deployment)

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

<Tabs>
<Tab label="OpenShift">

** Creates a Deployment **
```
oc apply -f deployment.yaml
```
** Gets Deployments **
```
oc get deployment my-deployment
```
** Gets the deployments description **
```
oc describe deployment my-deployment
```
** Edit the deployment **
```
oc edit deployment my-deployment
```
** Scale the deployment **
```
oc scale deployment/my-deployment --replicas=3
```
** Delete the deployment **
```
oc delete deployment my-deployment
```
</Tab>

<Tab label="IKS">

** Creates a Deployment **
```
kubectl apply -f <deploymentYAML>
```
** Get the deployment **
```
kubectl get deployment my-deployment
```
** Describe the deployment **
```
kubectl describe deployment my-deployment
```
** Edit the deployment **
```
kubectl edit deployment my-deployment
```
** Scale the deployment **
```
kubectl scale deployment/my-deployment --replicas=4
```
** Delete the deployment **
```
kubectl delete deployment my-deployment
```

</Tab>

</Tabs>