# Lab 7 Solution - Rolling Updates

## 1. Update the image

```bash
oc set image deployment/jedi-deployment jedi-ws=quay.io/nginx/nginx-unprivileged:1.29
oc annotate deployment/jedi-deployment kubernetes.io/change-cause="Upgrade to nginx 1.29"
```

## 2. Watch the rollout

```bash
oc rollout status deployment/jedi-deployment
```

```text title="Expected output"
Waiting for deployment "jedi-deployment" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "jedi-deployment" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "jedi-deployment" rollout to finish: 1 old replicas are pending termination...
deployment "jedi-deployment" successfully rolled out
```

In another terminal you can watch old pods being replaced one at a time:

```bash
oc get pods -l app=jedi -w
```

## 3. View the history

```bash
oc rollout history deployment/jedi-deployment
```

```text title="Expected output"
deployment.apps/jedi-deployment
REVISION  CHANGE-CAUSE
1         <none>
2         Upgrade to nginx 1.29
```

## 4. Deploy a broken release

```bash
oc set image deployment/jedi-deployment jedi-ws=quay.io/nginx/nginx-unprivileged:9.99
oc annotate deployment/jedi-deployment kubernetes.io/change-cause="Upgrade to nginx 9.99" --overwrite
oc rollout status deployment/jedi-deployment --timeout=60s
```

The rollout doesn't finish. `oc get pods -l app=jedi` shows one new pod stuck in `ErrImagePull` / `ImagePullBackOff`, **while the 3 old pods keep running**. By default a rolling update allows at most 25% of pods to be unavailable (`maxUnavailable`), so the broken release never takes down the working one.

## 5. Roll back

```bash
oc rollout undo deployment/jedi-deployment
oc rollout status deployment/jedi-deployment
```

`oc rollout undo` goes back to the previous revision (1.29). To go back further, use `oc rollout undo deployment/jedi-deployment --to-revision=1`.

Look at the history again:

```bash
oc rollout history deployment/jedi-deployment
```

```text title="Expected output"
deployment.apps/jedi-deployment
REVISION  CHANGE-CAUSE
1         <none>
3         Upgrade to nginx 9.99
4         Upgrade to nginx 1.29
```

Revision 2 is gone. A rollback doesn't reuse the old revision number. It copies that revision's Pod template into a new revision (4). The change cause came along with the template.

## Verify

```bash
oc get deployment jedi-deployment -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

```text title="Expected output"
quay.io/nginx/nginx-unprivileged:1.29
```
