# Config Maps

ConfigMaps allow you to decouple configuration artifacts from image content to keep containerized applications portable.

You can data from a ConfigMap in 3 different ways.
- As a single environment variable specific to a single key
- As a set of environment variables from all keys
- As a set of files, each key represented by a file on mounted volume

## Resources

**OpenShift**
- [Mapping Volumes](https://docs.openshift.com/container-platform/4.3/nodes/containers/nodes-containers-projected-volumes.html)

**IKS**
- [ConfigMaps](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)

## References

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
   name: my-cm
data:
   color: blue
   location: naboo
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
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

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
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

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  restartPolicy: Never
  containers:
    - name: myapp
      image: busybox
      command: ["/bin/sh", "-c", "env | sort"]
      envFrom:
        - configMapRef:
            name: my-cm
  restartPolicy: Never
```