---
tags:
  - Pods
  - Troubleshooting
---

# Debugging Applications

Kubernetes provides tools to help troubleshoot and debug problems with applications.

Debugging usually means understanding how the objects interact with each other (Deployment → ReplicaSet → Pod, Service → EndpointSlice → Pod), checking the status and events of each object, and finally checking the logs for any last clues.

## Resources

=== "OpenShift"

    <div class="grid cards" markdown>

      -   :fontawesome-solid-bug:{ .lg .middle } __Troubleshooting__

          ---

          Inspect pod status, events and logs, and start a debug shell with `oc debug`.

          [:octicons-arrow-right-24: Learn more](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/support/troubleshooting){ target="_blank"}

    </div>

=== "Kubernetes"

    <div class="grid cards" markdown>

      -   :fontawesome-solid-bug:{ .lg .middle } __Debugging Applications__

          ---

          Read about how to debug applications that are deployed into Kubernetes and not behaving correctly.

          [:octicons-arrow-right-24: Learn more](https://kubernetes.io/docs/tasks/debug/debug-application/){ target="_blank"}

      -   :fontawesome-solid-bug:{ .lg .middle } __Debugging Services__

          ---

          You've run your Pods through a Deployment and created a Service, but you get no response when you try to access it. What do you do?

          [:octicons-arrow-right-24: Learn more](https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/){ target="_blank"}

      -   :fontawesome-solid-bug:{ .lg .middle } __Debugging Running Pods__

          ---

          Use `kubectl debug` and ephemeral containers to troubleshoot pods that have no shell or debugging tools.

          [:octicons-arrow-right-24: Learn more](https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/){ target="_blank"}

    </div>

## References

### A broken application to practice on

Create a project and deploy an application that has several problems:

```bash
oc new-project debug
```

```bash
oc apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
  labels:
    app: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: app
          image: quay.io/nginx/nginx-unprivileged:1.290
          ports:
            - name: web
              containerPort: 8080
          livenessProbe:
            tcpSocket:
              port: 80
          resources:
            requests:
              memory: "800Gi"
              cpu: "10m"
---
apiVersion: v1
kind: Service
metadata:
  name: my-service
  labels:
    app: web
spec:
  selector:
    run: nginx
  ports:
    - name: http
      port: 80
      targetPort: http
EOF
```

Try to reach the service. It doesn't work:

```bash
oc port-forward service/my-service 8080:80
```

### Commands to debug with

=== "OpenShift"

    ``` Bash title="Status and events"
    oc get pods
    oc describe pod -l app=nginx
    oc get events --sort-by=.lastTimestamp
    oc status --suggest
    ```

    ``` Bash title="Inspect the deployment and service"
    oc get deployment my-deployment -o yaml
    oc describe service my-service
    oc get endpointslices -l kubernetes.io/service-name=my-service
    oc get pods --show-labels
    ```

    ``` Bash title="Look up what a field means"
    oc explain pod.spec.containers.resources.requests
    oc explain pod.spec.containers.livenessProbe
    ```

    ``` Bash title="Logs, including the previous crashed container"
    oc logs deployment/my-deployment
    oc logs <pod-name> --previous
    ```

    ``` Bash title="Start a debug copy of a pod with a shell"
    oc debug deployment/my-deployment
    ```

    ``` Bash title="Fix things"
    oc edit deployment my-deployment
    oc edit service my-service
    ```

=== "Kubernetes"

    ``` Bash title="Status and events"
    kubectl get pods
    kubectl describe pod -l app=nginx
    kubectl get events --sort-by=.lastTimestamp
    ```

    ``` Bash title="Inspect the deployment and service"
    kubectl get deployment my-deployment -o yaml
    kubectl describe service my-service
    kubectl get endpointslices -l kubernetes.io/service-name=my-service
    kubectl get pods --show-labels
    ```

    ``` Bash title="Look up what a field means"
    kubectl explain pod.spec.containers.resources.requests
    kubectl explain pod.spec.containers.livenessProbe
    ```

    ``` Bash title="Logs, including the previous crashed container"
    kubectl logs deployment/my-deployment
    kubectl logs <pod-name> --previous
    ```

    ``` Bash title="Attach an ephemeral debug container to a running pod"
    kubectl debug -it <pod-name> --image=busybox --target=app
    ```

    ``` Bash title="Fix things"
    kubectl edit deployment my-deployment
    kubectl edit service my-service
    ```

??? success "Show the answers"
    There are five problems. You'll find them roughly in this order, because each one hides the next:

    1. **The pod requests 800Gi of memory.** No node is that big, so the pod stays `Pending` with `FailedScheduling ... Insufficient memory`. On clusters with a ResourceQuota, such as the Developer Sandbox, the pod isn't even created: `oc get events` shows `exceeded quota` for the ReplicaSet. Request something like `64Mi`.
    2. **The image tag `1.290` doesn't exist.** Once the pod is scheduled, it shows `ErrImagePull` / `ImagePullBackOff`. Use `1.29`.
    3. **The liveness probe checks port 80**, but nginx listens on 8080. The container is restarted over and over. Probe port `8080`.
    4. **The service selector is `run: nginx`**, but the pods are labelled `app: nginx`, so the service has no endpoints. Select `app: nginx`.
    5. **The service `targetPort` is `http`**, but the container port is named `web`. Use `targetPort: web` or `8080`.

    After fixing them, `oc get endpointslices -l kubernetes.io/service-name=my-service` lists the pod IP, and `curl localhost:8080` through the port-forward returns the nginx welcome page.

## Activities

| Lab | Description |
| --- | ----------- |
| [Lab 3 - Debugging](../../../labs/kubernetes/lab3/index.md) | Find and fix everything that's broken in a deployment |
