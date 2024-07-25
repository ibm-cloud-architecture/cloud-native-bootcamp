# Secrets

Kubernetes secret objects let you store and manage sensitive information, such as passwords, OAuth tokens, and ssh keys. Putting this information in a secret is safer and more flexible than putting it verbatim in a Pod definition or in a container image.

A Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. Such information might otherwise be put in a Pod specification or in an image; putting it in a Secret object allows for more control over how it is used, and reduces the risk of accidental exposure.


## Resources

=== "OpenShift"

    [Image Pull Secrets :fontawesome-solid-globe:](https://docs.openshift.com/container-platform/4.13/openshift_images/managing_images/using-image-pull-secrets.html){ .md-button target="_blank"}

    [Secret Commands :fontawesome-solid-globe:](https://docs.openshift.com/container-platform/4.13/cli_reference/openshift_cli/developer-cli-commands.html#oc-create-secret-generic){ .md-button target="_blank"}

=== "Kubernetes"

    [Secrets :fontawesome-solid-globe:](https://kubernetes.io/docs/concepts/configuration/secret/){ .md-button target="_blank"}

    [Secret Distribution :fontawesome-solid-globe:](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/){ .md-button target="_blank"}

## References

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=
stringData:
  admin: administrator
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret-config
type: Opaque
stringData:
  config.yaml: |-
    apiUrl: "https://my.api.com/api/v1"
    username: token
    password: thesecrettoken
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-app
    image: bitnami/nginx
    ports:
      - containerPort: 8080
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: username
    envFrom:
      - secretRef:
          name: mysecret
    volumeMounts:
      - name: config
        mountPath: "/etc/secrets"
  volumes:
    - name: config
      secret:
        secretName: mysecret-config
```

=== "OpenShift"
    **Create files needed for rest of example.**
    ```
    echo -n 'admin' > ./username.txt
    echo -n '1f2d1e2e67df' > ./password.txt
    ```
    **Creating Secret from files.**
    ```
    oc create secret generic db-user-pass --from-file=./username.txt --from-file=./password.txt
    ```
    **Getting Secret**
    ```
    oc get secrets
    ```
    **Gets the Secret's Description.**
    ```
    oc describe secrets/db-user-pass
    ```

=== "Kubernetes"
    **Create files needed for rest of example.**
    ```
    echo -n 'admin' > ./username.txt
    echo -n '1f2d1e2e67df' > ./password.txt
    ```
    ** Creates the Secret from the files**
    ```
    kubectl create secret generic db-user-pass --from-file=./username.txt --from-file=./password.txt
    ```
    **Gets the Secret**
    ```
    kubectl get secrets
    ```
    **Gets the Secret's Description.**
    ```
    kubectl describe secrets/db-user-pass
    ```