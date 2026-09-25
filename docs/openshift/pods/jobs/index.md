---
tags:
  - Workloads
---

# Jobs and CronJobs

**Jobs**

A Job creates one or more Pods and ensures that a specified number of them successfully terminate. As pods successfully complete, the Job tracks the successful completions. When a specified number of successful completions is reached, the task (ie, Job) is complete. Deleting a Job will clean up the Pods it created.

**CronJobs**

One CronJob object is like one line of a crontab (cron table) file. It runs a job periodically on a given schedule, written in Cron format.

CronJob schedules use the time zone of the kube-controller-manager, which is usually UTC. Set `spec.timeZone` (for example `America/Chicago`) to schedule in a specific time zone. Use `successfulJobsHistoryLimit` and `failedJobsHistoryLimit` to control how many finished Jobs are kept, and `concurrencyPolicy` to decide whether runs may overlap.

## Resources

=== "OpenShift"

    [Jobs :fontawesome-solid-briefcase:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/nodes/using-jobs-and-daemon-sets#nodes-nodes-jobs){ .md-button target="_blank"}

    [CronJobs :fontawesome-solid-briefcase:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/nodes/using-jobs-and-daemon-sets#nodes-nodes-jobs){ .md-button target="_blank"}

=== "Kubernetes"

    [Jobs to Completion :fontawesome-solid-briefcase:](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/){ .md-button target="_blank"}

    [Cron Jobs :fontawesome-solid-briefcase:](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/){ .md-button target="_blank"}

    [Automated Tasks with Cron :fontawesome-solid-briefcase:](https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/){ .md-button target="_blank"}

## References

_It computes π to 2000 places and prints it out_

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
        - name: pi
          image: perl
          command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
```

_Running in parallel_

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  parallelism: 2
  completions: 3
  template:
    spec:
      containers:
        - name: pi
          image: perl
          command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
```

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: hello
              image: busybox
              args:
                - /bin/sh
                - -c
                - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
```

=== "OpenShift"

    **Gets Jobs**
    ```
    oc get jobs
    ```
    **Gets Job Description**
    ```
    oc describe job pi
    ```
    **Gets Pods and logs from the Job**
    ```
    oc get pods -l job-name=pi
    oc logs job/pi
    ```
    **Deletes Job**
    ```
    oc delete job pi
    ```
    **Gets CronJob**
    ```
    oc get cronjobs
    ```
    **Describes CronJob**
    ```
    oc describe cronjob hello
    ```
    **Runs the CronJob now, without waiting for the schedule**
    ```
    oc create job hello-now --from=cronjob/hello
    oc logs job/hello-now
    ```
    **Deletes CronJob**
    ```
    oc delete cronjob hello
    ```

=== "Kubernetes"

    **Gets Jobs**
    ```
    kubectl get jobs
    ```
    **Gets Job Description**
    ```
    kubectl describe job pi
    ```
    **Gets Pods and logs from the Job**
    ```
    kubectl get pods -l job-name=pi
    kubectl logs job/pi
    ```
    **Deletes Job**
    ```
    kubectl delete job pi
    ```
    **Gets CronJob**
    ```
    kubectl get cronjobs
    ```
    **Describes CronJob**
    ```
    kubectl describe cronjob hello
    ```
    **Runs the CronJob now, without waiting for the schedule**
    ```
    kubectl create job hello-now --from=cronjob/hello
    kubectl logs job/hello-now
    ```
    **Deletes CronJob**
    ```
    kubectl delete cronjob hello
    ```

## Activities

| Lab | Description |
| --- | ----------- |
| [Lab 8 - Cron Jobs](../../../labs/kubernetes/lab8/index.md) | Run a periodic task with a CronJob |
