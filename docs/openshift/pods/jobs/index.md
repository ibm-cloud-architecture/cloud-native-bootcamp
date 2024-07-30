# Jobs and CronJobs

**Jobs**

A Job creates one or more Pods and ensures that a specified number of them successfully terminate. As pods successfully complete, the Job tracks the successful completions. When a specified number of successful completions is reached, the task (ie, Job) is complete. Deleting a Job will clean up the Pods it created.

**CronJobs**

One CronJob object is like one line of a crontab (cron table) file. It runs a job periodically on a given schedule, written in Cron format.

All CronJob schedule: times are based on the timezone of the master where the job is initiated.

## Resources

=== "OpenShift"

    [Jobs :fontawesome-solid-briefcase:](https://docs.openshift.com/container-platform/4.3/nodes/jobs/nodes-nodes-jobs.html){ .md-button target="_blank"}

    [CronJobs :fontawesome-solid-briefcase:](https://docs.openshift.com/container-platform/4.3/nodes/jobs/nodes-nodes-jobs.html#nodes-nodes-jobs-creating-cron_nodes-nodes-jobs){ .md-button target="_blank"}

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
apiVersion: batch/v1beta1
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
    **Gets Pods from the Job**
    ```
    oc get pods
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
    oc describe cronjobs pi
    ```
    **Gets Pods from CronJob**
    ```
    oc get pods
    ```
    **Deletes CronJob**
    ```
    oc delete cronjobs pi
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
    **Gets Pods from the Job**
    ```
    kubectl get pods
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
    kubectl describe cronjobs pi
    ```
    **Gets Pods from CronJob**
    ```
    kubectl get pods
    ```
    **Deletes CronJob**
    ```
    kubectl delete cronjobs pi
    ```

## Activities

| Task                  | Description                                        | Link                                                      |
| --------------------- | -------------------------------------------------- | :-------------------------------------------------------- |
| **_Try It Yourself_** |                                                    |                                                           |
| Rolling Updates Lab   | Create a Rolling Update for your application.      | [Rolling Updates](../../../labs/kubernetes/lab6/index.md) |
| Cron Jobs Lab         | Using Tekton to test new versions of applications. | [Crons Jobs](../../../labs/kubernetes/lab7/index.md)      |
