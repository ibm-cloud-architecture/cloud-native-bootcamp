# Debugging Applications

Kubernetes provides tools to help troubleshoot and debug problems with applications.

Usually is getting familiar with how primitives objects interact with each other, checking the status of objects, and finally checking logs for any last resource clues.

## Resources

=== "OpenShift"

    <div class="grid cards" markdown>

      -   :fontawesome-solid-bug:{ .lg .middle } __Debugging ODO__

          ---

          OpenShift Toolkit is an IDE plugin available on VS Code and JetBrains IDEs, that allows you to do all things that [`odo`](https://odo.dev/docs/introduction){ target="_blank"} does, i.e. create, test, debug and deploy cloud-native applications on a cloud-native environment in simple steps.

          [:octicons-arrow-right-24: Getting started](https://odo.dev/docs/user-guides/advanced/debugging-with-openshift-toolkit){ target="_blank"}

    </div>

=== "Kubernetes"

    <div class="grid cards" markdown>

      -   :fontawesome-solid-bug:{ .lg .middle } __Debugging Applications__

          ---

          Read about how to debug applications that are deployed into Kubernetes and not behaving correctly.

          [:octicons-arrow-right-24: Learn more](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-application/){ target="_blank"}

      -   :fontawesome-solid-bug:{ .lg .middle } __Debugging Services__

          ---

          You've run your Pods through a Deployment and created a Service, but you get no response when you try to access it. What do you do?

          [:octicons-arrow-right-24: Learn more](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-service/){ target="_blank"}

      -   :fontawesome-solid-bug:{ .lg .middle } __Debugging Replication Controllers__

          ---

          Read about how to debug replication controllers that are deployed into Kubernetes and not behaving correctly.

          [:octicons-arrow-right-24: Learn more](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/#debugging-replication-controllers){ target="_blank"}

    </div>

## References

=== "OpenShift"

     **MacOS/Linux/Windows command:**
         ```
         oc apply -f https://gist.githubusercontent.com/csantanapr/e823b1bfab24186a26ae4f9ec1ff6091/raw/1e2a0cca964c7b54ce3df2fc3fbf33a232511877/debugk8s-bad.yaml
         ```

     **Expose the service using port-forward**
     ```
     oc port-forward service/my-service 8080:80 -n debug
     ```

     **Try to access the service**
     ```
     curl http://localhost:8080
     ```

     **Try Out these Commands to Debug**
     ```
     oc get pods --all-namespaces
     ```
     ```
     oc project debug
     ```
     ```
     oc get deployments
     ```
     ```
     oc describe pod
     ```
     ```
     oc explain Pod.spec.containers.resources.requests
     ```
     ```
     oc explain Pod.spec.containers.livenessProbe
     ```
     ```
     oc edit deployment
     ```
     ```
     oc logs
     ```
     ```
     oc get service
     ```
     ```
     oc get ep
     ```
     ```
     oc describe service
     ```
     ```
     oc get pods --show-labels
     ```
     ```
     oc get deployment --show-labels
     ```

=== "Kubernetes"

     **MacOS/Linux/Windows command:**
     ```
     kubectl apply -f https://gist.githubusercontent.com/csantanapr/e823b1bfab24186a26ae4f9ec1ff6091/raw/1e2a0cca964c7b54ce3df2fc3fbf33a232511877/debugk8s-bad.yaml
     ```

     **Expose the service using port-forward**
     ```
     kubectl port-forward service/my-service 8080:80 -n debug
     ```

     **Try to access the service**
     ```
     curl http://localhost:8080
     ```

     **Try Out these Commands to Debug**
     ```
     kubectl get pods --all-namespaces
     ```
     ```
     kubectl config set-context --current --namespace=debug
     ```
     ```
     kubectl get deployments
     ```
     ```
     kubectl describe pod
     ```
     ```
     kubectl explain Pod.spec.containers.resources.requests
     ```
     ```
     kubectl explain Pod.spec.containers.livenessProbe
     ```
     ```
     kubectl edit deployment
     ```
     ```
     kubectl logs
     ```
     ```
     kubectl get service
     ```
     ```
     kubectl get ep
     ```
     ```
     kubectl describe service
     ```
     ```
     kubectl get pods --show-labels
     ```
     ```
     kubectl get deployment --show-labels
     ```

## Activities

The continuous integration activities focus around Tekton the integration platform. These labs will show you how to build pipelines and test your code before deployment.

| Task                  | Description                                                      | Link                                                | Est. Time |
| --------------------- | ---------------------------------------------------------------- | :-------------------------------------------------- | --------- |
| **_Try It Yourself_** |                                                                  |                                                     |
| Debugging             | Find which service is breaking in your cluster and find out why. | [Debugging](../../../labs/kubernetes/lab5/index.md) | 30 min    |
