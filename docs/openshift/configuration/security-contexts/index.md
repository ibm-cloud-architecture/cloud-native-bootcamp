# Security Contexts

A **security context** defines privilege and access control settings for a Pod or container: which user and group it runs as, which Linux capabilities it has, whether it can escalate privileges, whether its root filesystem is read-only, and which seccomp and SELinux profiles apply.

- `spec.securityContext` (a `PodSecurityContext`) applies to every container in the Pod, for example `runAsUser`, `runAsGroup`, `fsGroup` and `seccompProfile`.
- `spec.containers[].securityContext` applies to a single container and overrides the Pod-level values, for example `allowPrivilegeEscalation`, `capabilities`, `readOnlyRootFilesystem` and `privileged`.

## How the cluster enforces security contexts

=== "OpenShift"

    OpenShift uses **Security Context Constraints (SCCs)**. By default, every Pod is admitted under the `restricted-v2` SCC, which:

    - runs the container as a **random UID** from a range allocated to the project, ignoring the image's `USER`, with group `0` (root group) as a supplemental group
    - drops **all** Linux capabilities and blocks privilege escalation
    - applies the `RuntimeDefault` seccomp profile and a per-project SELinux context
    - blocks `hostPath` volumes, host networking and privileged containers

    OpenShift **fills in** these settings for you. A Pod that doesn't set a security context is simply given one. A Pod that asks for more (for example `runAsUser: 0` or `privileged: true`) is rejected unless its ServiceAccount has been granted a less restrictive SCC by a cluster administrator.

    ```bash
    # UID range assigned to your project
    oc get project $(oc project -q) -o jsonpath='{.metadata.annotations.openshift\.io/sa\.scc\.uid-range}{"\n"}'

    # Which SCC admitted a pod
    oc get pod <pod> -o jsonpath='{.metadata.annotations.openshift\.io/scc}{"\n"}'
    ```

=== "Kubernetes"

    Upstream Kubernetes uses **[Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/)**, configured per namespace with labels such as `pod-security.kubernetes.io/enforce: restricted`. Unlike SCCs, Pod Security Admission only **validates** Pods and never changes them. Under the `restricted` level, you must set the secure values yourself or the Pod is rejected.

    ```bash
    kubectl label namespace dev pod-security.kubernetes.io/enforce=restricted
    ```

## Resources

=== "OpenShift"

    [Managing Security Context Constraints :fontawesome-solid-shield-halved:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/authentication_and_authorization/managing-pod-security-policies){ .md-button target="_blank"}

=== "Kubernetes"

    [Security Contexts :fontawesome-solid-shield-halved:](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/){ .md-button target="_blank"}

    [Pod Security Standards :fontawesome-solid-shield-halved:](https://kubernetes.io/docs/concepts/security/pod-security-standards/){ .md-button target="_blank"}

## Example

This Pod follows the `restricted` rules and adds a **read-only root filesystem**. The app can only write to the `emptyDir` volume mounted at `/tmp`.

=== "OpenShift"

    ```yaml title="security-context-demo.yaml"
    apiVersion: v1
    kind: Pod
    metadata:
      name: security-context-demo
    spec:
      containers:
        - name: demo
          image: registry.access.redhat.com/ubi9/ubi-minimal
          command:
            - sh
            - -c
            - |
              id
              touch /tmp/ok && echo "can write to /tmp"
              touch /hello 2>/dev/null || echo "cannot write to /"
              sleep infinity
          securityContext:
            readOnlyRootFilesystem: true
          volumeMounts:
            - name: tmp
              mountPath: /tmp
      volumes:
        - name: tmp
          emptyDir: {}
    ```

    The remaining restricted settings (UID, capabilities, seccomp, privilege escalation) are added by the `restricted-v2` SCC.

=== "Kubernetes"

    ```yaml title="security-context-demo.yaml"
    apiVersion: v1
    kind: Pod
    metadata:
      name: security-context-demo
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        runAsGroup: 0
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: demo
          image: registry.access.redhat.com/ubi9/ubi-minimal
          command:
            - sh
            - -c
            - |
              id
              touch /tmp/ok && echo "can write to /tmp"
              touch /hello 2>/dev/null || echo "cannot write to /"
              sleep infinity
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]
          volumeMounts:
            - name: tmp
              mountPath: /tmp
      volumes:
        - name: tmp
          emptyDir: {}
    ```

    !!! warning
        Don't hard-code `runAsUser` in manifests meant for OpenShift. A fixed UID outside the project's range is rejected by `restricted-v2`.

```bash
oc apply -f security-context-demo.yaml
oc logs security-context-demo
```

```text title="Expected output (the UID differs per project)"
uid=1000680000(1000680000) gid=0(root) groups=0(root),1000680000
can write to /tmp
cannot write to /
```

See what the cluster applied:

```bash
oc get pod security-context-demo -o jsonpath='{.spec.securityContext}{"\n"}{.spec.containers[0].securityContext}{"\n"}'
```

## Try it: a pod that asks for too much

Try to create a Pod that runs as root:

```yaml title="root-pod.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: root-pod
spec:
  containers:
    - name: demo
      image: registry.access.redhat.com/ubi9/ubi-minimal
      command: ["sleep", "infinity"]
      securityContext:
        runAsUser: 0
```

```bash
oc apply -f root-pod.yaml
```

OpenShift rejects it with an error like `pods "root-pod" is forbidden: unable to validate against any security context constraint: ... runAsUser: Invalid value: 0: must be in the ranges: [1000680000, 1000689999]`.
