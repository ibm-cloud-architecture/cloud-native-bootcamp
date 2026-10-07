---
tags:
  - Solution
  - Packaging
---

# Lab 12 Solution - Helm & Kustomize

The solutions for each step are inline in the lab. This page covers step 5: the `test` overlay.

```yaml title="kustomize/overlays/test/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
components:
  - ../../components/openshift-route
labels:
  - pairs:
      environment: test
    includeSelectors: false
replicas:
  - name: greeting
    count: 2
configMapGenerator:
  - name: greeting-config
    literals:
      - GREETING=Hello from test
```

```bash
oc new-project greeting-test
oc apply -k kustomize/overlays/test -n greeting-test
oc rollout status deployment/greeting -n greeting-test
oc get pods -n greeting-test -l app=greeting
curl -sk "https://$(oc get route greeting -n greeting-test -o jsonpath='{.spec.host}')/greeting"
```

```json title="Expected output"
{"message":"Hello from test","name":"World"}
```

!!! tip "Why `includeSelectors: false`?"
    A Deployment's selector can't be changed after it's created. `includeSelectors: false` adds the label to metadata only, not to selectors, so you can add or change environment labels later without having to delete and recreate the Deployment.

## Helm: what each step showed

| Step | Command | Result |
| --- | --- | --- |
| Install | `helm install greeting ./helm/greeting --set greeting=...` | Revision 1 |
| Upgrade | `helm upgrade ... --reuse-values --set replicaCount=2` | Revision 2, 2 pods, same greeting |
| Test | `helm test greeting` | The test pod calls the service and checks the greeting: `Phase: Succeeded` |
| Rollback | `helm rollback greeting 1` | Revision 3 with revision 1's settings (1 pod) |
| Prod values | `helm upgrade --install ... -f values-prod.yaml` | 3 pods, more memory, a ServiceMonitor |
