---
tags:
  - Configuration
---

# Config Maps

ConfigMaps allow you to decouple configuration artifacts from image content to keep containerized applications portable.

You can data from a ConfigMap in 3 different ways.

- As a single environment variable specific to a single key
- As a set of environment variables from all keys
- As a set of files, each key represented by a file on mounted volume

## Resources

=== "OpenShift"

    [Mapping Volumes :fontawesome-solid-map:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/nodes/working-with-containers#nodes-containers-projected-volumes){ .md-button target="_blank"}

=== "Kubernetes"

    [ConfigMaps :fontawesome-solid-map:](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/){ .md-button target="_blank"}

## References

```yaml title="ConfigMap"
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-cm
data:
  color: blue
  location: naboo
```

```yaml title="Single key as an environment variable"
apiVersion: v1
kind: Pod
metadata:
  name: cm-env-var
spec:
  restartPolicy: Never
  containers:
    - name: myapp
      image: busybox
      command: ["echo"]
      args: ["color is $(MY_VAR)"]
      env:
        - name: MY_VAR
          valueFrom:
            configMapKeyRef:
              name: my-cm
              key: color
```

```yaml title="All keys as files in a volume"
apiVersion: v1
kind: Pod
metadata:
  name: cm-volume
spec:
  restartPolicy: Never
  containers:
    - name: myapp
      image: busybox
      command:
        [
          "sh",
          "-c",
          "ls -l /etc/config; echo located at $(cat /etc/config/location)",
        ]
      volumeMounts:
        - name: config-volume
          mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: my-cm
```

```yaml title="All keys as environment variables"
apiVersion: v1
kind: Pod
metadata:
  name: cm-env-from
spec:
  restartPolicy: Never
  containers:
    - name: myapp
      image: busybox
      command: ["/bin/sh", "-c", "env | sort"]
      envFrom:
        - configMapRef:
            name: my-cm
```

=== "OpenShift"

    ``` Bash title="Create the ConfigMap from literals instead of YAML"
    oc create configmap my-cm --from-literal=color=blue --from-literal=location=naboo
    ```

    ``` Bash title="Create a ConfigMap from a file"
    oc create configmap app-config --from-file=app.properties
    ```

    ``` Bash title="See what each pod printed"
    oc logs cm-env-var
    oc logs cm-volume
    oc logs cm-env-from
    ```

=== "Kubernetes"

    ``` Bash title="Create the ConfigMap from literals instead of YAML"
    kubectl create configmap my-cm --from-literal=color=blue --from-literal=location=naboo
    ```

    ``` Bash title="Create a ConfigMap from a file"
    kubectl create configmap app-config --from-file=app.properties
    ```

    ``` Bash title="See what each pod printed"
    kubectl logs cm-env-var
    kubectl logs cm-volume
    kubectl logs cm-env-from
    ```

!!! tip
    Environment variables are read only when the container starts. Files mounted from a ConfigMap are updated automatically (after a short delay) when the ConfigMap changes, unless you mount them with `subPath`.

