# Lab 6 - Pod Configuration

<span class="lab-badge">30 min</span> <span class="lab-badge">Intermediate</span>

## Problem

Write a Pod manifest named `yoda-service-pod.yaml`, create the Pod in the cluster, and prove it's configured correctly.

The Pod must meet these requirements:

- The Pod is named `yoda-service` and uses the image `quay.io/nginx/nginx-unprivileged:1.29`. You don't need a custom command or arguments.
- **Configuration file:** the container needs this configuration data:

    ```properties
    yoda.baby.power=100000000
    yoda.strength=10
    ```

    Store it in a ConfigMap named `yoda-service-config`, under the key `yoda.cfg`, and mount it into the container so the file appears at `/etc/yoda-service/yoda.cfg`.

- **Resources:** the container requests `64Mi` of memory and `250m` of CPU, and is limited to `128Mi` of memory and `500m` of CPU.
- **Secret:** the container needs a database password, `0penSh1ftRul3s!`. Store it in a Secret named `yoda-db-password` under the key `password`, and pass it to the container as the environment variable `DB_PASSWORD`.
- **Identity:** the Pod runs as the ServiceAccount `yoda-svc`. Create the ServiceAccount if it doesn't already exist.

## Setup

```bash
oc new-project lab6
```

## Verification

```bash
# The configuration file is mounted
oc exec yoda-service -- cat /etc/yoda-service/yoda.cfg

# The secret is available as an environment variable
oc exec yoda-service -- printenv DB_PASSWORD

# The Pod runs as the right ServiceAccount
oc get pod yoda-service -o jsonpath='{.spec.serviceAccountName}{"\n"}'

# Requests and limits are set (QoS class "Burstable")
oc get pod yoda-service -o jsonpath='{.spec.containers[0].resources}{"\n"}{.status.qosClass}{"\n"}'
```

## Cleanup

```bash
oc delete project lab6
```
