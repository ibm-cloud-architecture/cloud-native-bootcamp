# Lab 8 - Cron Jobs

<span class="lab-badge">20 min</span> <span class="lab-badge">Beginner</span>

## Problem

Your commander runs a simple status check on the X-Wing fleet by hand, every few minutes. To save time, you've been asked to automate it with a CronJob.

The CronJob must meet these requirements:

- The CronJob is named `xwing-cronjob`.
- It runs every two minutes, using the cron expression `*/2 * * * *`.
- It uses the image `registry.access.redhat.com/ubi9/ubi-minimal`.
- The container runs this command, which prints the date and the fleet status:

    ```bash
    /bin/sh -c 'date; echo "X-Wing fleet status: all systems go"'
    ```

- Failed jobs are retried (`restartPolicy: OnFailure`).
- Only the last 3 successful jobs are kept.

## Setup

```bash
oc new-project lab8
```

## Verification

1. Check the CronJob. After a couple of minutes, `LAST SCHEDULE` shows when it last ran:

    ```bash
    oc get cronjob xwing-cronjob
    ```

2. You don't have to wait for the schedule. Trigger a run now by creating a Job from the CronJob's template:

    ```bash
    oc create job xwing-manual --from=cronjob/xwing-cronjob
    oc wait --for=condition=Complete job/xwing-manual --timeout=60s
    oc logs job/xwing-manual
    ```

3. Watch the scheduled Jobs appear every two minutes, then read the logs of all of them:

    ```bash
    oc get jobs -w
    ```

    ```bash
    for job in $(oc get jobs -o name); do
      echo "== ${job}"
      oc logs "${job}"
    done
    ```

## Cleanup

```bash
oc delete project lab8
```
