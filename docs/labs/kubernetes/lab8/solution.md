---
tags:
  - Solution
  - Workloads
---

# Lab 8 Solution - Cron Jobs

```yaml title="xwing-cronjob.yaml"
apiVersion: batch/v1
kind: CronJob
metadata:
  name: xwing-cronjob
spec:
  schedule: "*/2 * * * *"
  successfulJobsHistoryLimit: 3
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: xwing-status
              image: registry.access.redhat.com/ubi9/ubi-minimal
              command: ["/bin/sh", "-c"]
              args: ['date; echo "X-Wing fleet status: all systems go"']
```

```bash
oc apply -f xwing-cronjob.yaml
oc create job xwing-manual --from=cronjob/xwing-cronjob
oc wait --for=condition=Complete job/xwing-manual --timeout=60s
oc logs job/xwing-manual
```

```text title="Expected output"
Thu Sep 24 23:20:00 UTC 2026
X-Wing fleet status: all systems go
```

## Notes

- **Time zones**: schedules use the kube-controller-manager's time zone, usually UTC. Set `spec.timeZone` (for example `timeZone: America/New_York`) to schedule in a specific zone.
- **Missed runs**: set `startingDeadlineSeconds` to control whether a run that was missed (for example, because the cluster was down) still starts late.
- **Overlapping runs**: `concurrencyPolicy: Forbid` skips a run if the previous one is still going. `Replace` cancels the old one.
- Use [crontab.guru](https://crontab.guru/) to check cron expressions.
