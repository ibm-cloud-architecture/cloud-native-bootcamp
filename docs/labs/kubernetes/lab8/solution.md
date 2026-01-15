# Kubernetes Lab 8 - Cron Jobs

## Solution

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: xwing-cronjob
spec:
  schedule: "*/2 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: xwing-status
            image: ibmcase/xwing-status:1.0
            args:
            - /usr/sbin/xwing-status.sh
          restartPolicy: OnFailure
```

> **Note:** The CronJob API was moved from `batch/v1beta1` to `batch/v1` in Kubernetes 1.21. Use `batch/v1` for clusters running Kubernetes 1.21 or later.

## Verify the CronJob

```bash
kubectl get cronjob xwing-cronjob
```
