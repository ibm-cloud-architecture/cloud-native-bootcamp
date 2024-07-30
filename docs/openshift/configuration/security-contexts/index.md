# Security Contexts

A security context defines privilege and access control settings for a Pod or Container.

To specify security settings for a Pod, include the securityContext field in the Pod specification. The securityContext field is a PodSecurityContext object. The security settings that you specify for a Pod apply to all Containers in the Pod.

## Resources

=== "OpenShift"

    [Managing Security Contexts :fontawesome-solid-shield-halved:](https://docs.openshift.com/container-platform/4.13/authentication/managing-security-context-constraints.html){ .md-button target="_blank"}

=== "Kubernetes"

    [Security Contexts :fontawesome-solid-shield-halved:](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/){ .md-button target="_blank"}

## References

Setup minikube VM with users

```
minikube ssh
```

```
su -
```

```
echo "container-user-0:x:2000:2000:-:/home/container-user-0:/bin/bash" >> /etc/passwd
echo "container-user-1:x:2001:2001:-:/home/container-user-1:/bin/bash" >> /etc/passwd
echo "container-group-0:x:3000:" >>/etc/group
echo "container-group-1:x:3001:" >>/etc/group
mkdir -p /etc/message/
echo "Hello, World!" | sudo tee -a /etc/message/message.txt
chown 2000:3000 /etc/message/message.txt
chmod 640 /etc/message/message.txt
```

Using the this `securityContext` the container will be able to read the file `/message/message.txt`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-securitycontext-pod
spec:
  restartPolicy: Never
  securityContext:
    runAsUser: 2000
    runAsGroup: 3000
    fsGroup: 3000
  containers:
    - name: myapp-container
      image: busybox
      command: ["sh", "-c", "cat /message/message.txt && sleep 3600"]
      volumeMounts:
        - name: message-volume
          mountPath: /message
  volumes:
    - name: message-volume
      hostPath:
        path: /etc/message
```

Using the this `securityContext` the container should NOT be able to read the file `/message/message.txt`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-securitycontext-pod
spec:
  restartPolicy: Never
  securityContext:
    runAsUser: 2001
    runAsGroup: 3001
    fsGroup: 3001
  containers:
    - name: myapp-container
      image: busybox
      command: ["sh", "-c", "cat /message/message.txt && sleep 3600"]
      volumeMounts:
        - name: message-volume
          mountPath: /message
  volumes:
    - name: message-volume
      hostPath:
        path: /etc/message
```

**_Run to see the errors_**

=== "OpenShift"

    ``` Bash title="Get Pod Logs"
    oc logs my-securitycontext-pod
    ```

    ``` Bash title="Should return"
    cat: can't open '/message/message.text': Permission denied
    ```

=== "Kubernetes"

    ``` Bash title="Get Pod Logs"
    kubectl logs my-securitycontext-pod
    ```

    ``` Bash title="Should return"
    cat: can't open '/message/message.txt': Permission denied
    ```
