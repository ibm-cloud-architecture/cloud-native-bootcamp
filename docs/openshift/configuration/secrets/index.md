---
tags:
  - Configuration
  - Security
---

# Secrets

Kubernetes secret objects let you store and manage sensitive information, such as passwords, OAuth tokens, and ssh keys. Putting this information in a secret is safer and more flexible than putting it verbatim in a Pod definition or in a container image.

A Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. Such information might otherwise be put in a Pod specification or in an image; putting it in a Secret object allows for more control over how it is used, and reduces the risk of accidental exposure.

!!! warning "Secrets are encoded, not encrypted"
    Values in `data` are only base64-encoded. Anyone who can read the Secret, or who can create a pod in the namespace, can read its values. Protect Secrets with RBAC, enable encryption at rest for etcd, and never commit Secret manifests with real values to Git. For production, store credentials in an external secret manager (for example HashiCorp Vault or IBM Cloud Secrets Manager) and sync them in with the External Secrets Operator or the Secrets Store CSI driver.

## Resources

=== "OpenShift"


    [Image Pull Secrets :fontawesome-solid-key:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/images/managing-images#using-image-pull-secrets){ .md-button target="_blank"}

    [Secret Commands :fontawesome-solid-key:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/cli_tools/openshift-cli-oc#cli-developer-commands){ .md-button target="_blank"}

=== "Kubernetes"

    [Secrets :fontawesome-solid-key:](https://kubernetes.io/docs/concepts/configuration/secret/){ .md-button target="_blank"}

    [Secret Distribution :fontawesome-solid-key:](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/){ .md-button target="_blank"}

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
      image: quay.io/nginx/nginx-unprivileged:1.29
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

    **Create files needed for rest of example**

    ```
    echo -n 'admin' > ./username.txt
    echo -n '1f2d1e2e67df' > ./password.txt
    ```

    **Creating Secret from files**

    ```
    oc create secret generic db-user-pass --from-file=./username.txt --from-file=./password.txt
    ```

    **Getting Secret**

    ```
    oc get secrets
    ```

    **Gets the Secret's Description**

    ```
    oc describe secrets/db-user-pass
    ```

    **Reads the decoded values**

    ```
    oc extract secret/db-user-pass --to=-
    ```

=== "Kubernetes"

    **Create files needed for rest of example**
    ```
    echo -n 'admin' > ./username.txt
    echo -n '1f2d1e2e67df' > ./password.txt
    ```
    **Creates the Secret from the files**
    ```
    kubectl create secret generic db-user-pass --from-file=./username.txt --from-file=./password.txt
    ```
    **Gets the Secret**
    ```
    kubectl get secrets
    ```
    **Gets the Secret's Description**
    ```
    kubectl describe secrets/db-user-pass
    ```
