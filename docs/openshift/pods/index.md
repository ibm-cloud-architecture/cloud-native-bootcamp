# Pods

A Pod is the basic execution unit of a Kubernetes application–the smallest and simplest unit in the Kubernetes object model that you create or deploy. A Pod represents processes running on your Cluster.

A Pod encapsulates an application’s container (or, in some cases, multiple containers), storage resources, a unique network IP, and options that govern how the container(s) should run. A Pod represents a unit of deployment: a single instance of an application in Kubernetes, which might consist of either a single container or a small number of containers that are tightly coupled and that share resources.

## Resources

=== "OpenShift"

    <div class="grid cards" markdown>

      -   :fontawesome-solid-globe:{ .lg .middle } __About Pods__

          ---

          Install [`mkdocs-material`](#) with [`pip`](#) and get up and running in minutes

          [:octicons-arrow-right-24: Getting started](https://docs.openshift.com/container-platform/4.3/nodes/pods/nodes-pods-using.html){ target="_blank"}

      -   :fontawesome-solid-globe:{ .lg .middle } __Cluster Configuration for Pods__

          ---

          Install [`mkdocs-material`](#) with [`pip`](#) and get up and running in minutes

          [:octicons-arrow-right-24: Getting started](https://docs.openshift.com/container-platform/4.3/nodes/pods/nodes-pods-configuring.html){ target="_blank"}

      -   :fontawesome-solid-globe:{ .lg .middle } __Pod Autoscaling__

          ---

          Install [`mkdocs-material`](#) with [`pip`](#) and get up and running in minutes

          [:octicons-arrow-right-24: Getting started](https://docs.openshift.com/container-platform/4.3/nodes/pods/nodes-pods-autoscaling.html){ target="_blank"}

    </div>

=== "Kubernetes"

    <div class="grid cards" markdown>

      -   :fontawesome-solid-globe:{ .lg .middle } __Pod Overview__

          ---

          Install [`mkdocs-material`](#) with [`pip`](#) and get up and running in minutes

          [:octicons-arrow-right-24: Getting started](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/){ target="_blank"}

      -   :fontawesome-solid-globe:{ .lg .middle } __Pod Lifecycle__

          ---

          Install [`mkdocs-material`](#) with [`pip`](#) and get up and running in minutes

          [:octicons-arrow-right-24: Getting started](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/){ target="_blank"}

      -   :fontawesome-solid-globe:{ .lg .middle } __Pod Usage__

          ---

          Install [`mkdocs-material`](#) with [`pip`](#) and get up and running in minutes

          [:octicons-arrow-right-24: Getting started](https://kubernetes.io/docs/concepts/workloads/pods/pod/){ target="_blank"}

    </div>

## References

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
    - name: myapp-container
      image: busybox
      command: ["sh", "-c", "echo Hello Kubernetes! && sleep 3600"]
```

=== "OpenShift"

    **Create Pod using yaml file**

    ```
    oc apply -f pod.yaml
    ```

    **Get Current Pods in Project**

    ```
    oc get pods
    ```

    **Get Pods with their IP and node location**

    ```
    oc get pods -o wide
    ```

    **Get Pod's Description**

    ```
    oc describe pod myapp-pod
    ```

    **Get the logs**

    ```
    oc logs myapp-pod
    ```

    **Delete a Pod**

    ```
    oc delete pod myapp-pod
    ```

=== "Kubernetes"

    **Create Pod using yaml file**

    ```
    kubectl apply -f pod.yaml
    ```

    **Get Current Pods in Project**

    ```
    kubectl get pods
    ```

    **Get Pods with their IP and node location**

    ```
    kubectl get pods -o wide
    ```

    **Get Pod's Description**

    ```
    kubectl describe pod myapp-pod
    ```

    **Get the logs**

    ```
    kubectl logs myapp-pod
    ```

    **Delete a Pod**

    ```
    kubectl delete pod myapp-pod
    ```

## Activities

| Task                  | Description                                       | Link                                                |
| --------------------- | ------------------------------------------------- | :-------------------------------------------------- |
| **_Try It Yourself_** |                                                   |                                                     |
| Creating Pods         | Create a Pod YAML file to meet certain parameters | [Pod Creation](../../labs/kubernetes/lab1/index.md) |
