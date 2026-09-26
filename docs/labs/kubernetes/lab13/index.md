---
tags:
  - Lab
  - Observability
  - Intermediate
---

# Lab 13 - Observability

<span class="lab-badge">45 min</span> <span class="lab-badge">Intermediate</span>

## Problem

Users say the `greeting` service is "sometimes slow and sometimes broken". Instrument and observe it so you can prove it:

- **Metrics:** collect the service's request rate, error rate and latency with Prometheus.
- **Alerts:** fire an alert when more than 10% of requests fail.
- **Traces:** find a slow request in Jaeger and see which part of it was slow.
- **Logs:** jump from a log line to its trace by using the trace ID.

See [Observability](../../../openshift/observability/index.md) for the concepts.

## Prerequisites

- An OpenShift cluster with **user workload monitoring** enabled. On the local lab cluster, use `local-cluster.sh --monitoring` instead. See [Lab Environments](../../../lab-environments.md).
- `oc`, `helm`, and a clone of the bootcamp repository. Run the commands from its `sample-app` directory, as in [Lab 12](../lab12/index.md).

??? info "Cluster admins: enable user workload monitoring"
    On OpenShift Local or your own cluster, enable it once as `kubeadmin`:

    ```bash
    oc apply -f - <<'EOF'
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: cluster-monitoring-config
      namespace: openshift-monitoring
    data:
      config.yaml: |
        enableUserWorkload: true
    EOF
    oc get pods -n openshift-user-workload-monitoring   # wait until they're Running
    ```

    Users who aren't project admins also need the `monitoring-edit` role in their project: `oc policy add-role-to-user monitoring-edit <user> -n <project>`.

## Setup

1. Create a project and deploy Jaeger, which receives traces and serves a UI:

    ```bash
    oc new-project observability-lab
    oc apply -f observability/jaeger.yaml
    oc rollout status deployment/jaeger
    oc expose service jaeger --port=ui
    echo "http://$(oc get route jaeger -o jsonpath='{.spec.host}')"
    ```

2. Install the `greeting` chart with tracing pointed at Jaeger and a ServiceMonitor for Prometheus:

    ```bash
    helm install greeting ./helm/greeting --wait \
      --set tracing.otlpEndpoint=http://jaeger:4318 \
      --set serviceMonitor.enabled=true
    oc logs deployment/greeting | grep tracing
    ```

    The log shows `"msg":"tracing enabled","endpoint":"http://jaeger:4318"`.

## Part 1: Metrics

3. Look at the raw metrics the app exposes:

    ```bash
    oc port-forward service/greeting 8080:8080
    ```

    ```bash
    curl -s "localhost:8080/greeting?name=metrics"; curl -s localhost:8080/fail
    curl -s localhost:8080/metrics | grep ^greeting_
    ```

    You'll see counters like `greeting_requests_total{code="500",path="/fail"} 1` and histogram buckets for `greeting_request_duration_seconds`.

4. Start the load generator. For 5 minutes it sends normal, failing and slow requests:

    ```bash
    oc apply -f observability/load.yaml
    ```

5. Wait a minute, then query the metrics. In the web console, go to **Observe > Metrics** in your project. On the local cluster, run `kubectl -n monitoring port-forward svc/prometheus-operated 9090` and open <http://localhost:9090>. Write PromQL queries for:

    - the request **rate** per status code
    - the **error ratio** (the share of requests that return 5xx)
    - the **95th percentile latency** of `/greeting`

## Part 2: Alerts

6. Create the alert rule:

    ```bash
    oc apply -f observability/greeting-alerts.yaml
    ```

7. Watch the alert in **Observe > Alerts**, or at <http://localhost:9090/alerts> on the local cluster. It's **Pending** first. The load sends one failing request for every three, about a 33% error ratio, so after the rule's `for: 1m` it changes to **Firing**. Why does the rule use a ratio and `for: 1m`, not "any 500 error"?

## Part 3: Traces

8. Open the Jaeger UI (the Route URL from step 1, or `oc port-forward service/jaeger 16686:16686` and <http://localhost:16686>). Search for service **greeting** with **Min Duration** `250ms`.

9. Open one of the slow traces. Which span takes most of the time, and what are its attributes?

## Part 4: Logs

10. The app writes JSON logs that include the trace ID. Find a slow request in the logs, then look its `trace_id` up in Jaeger (paste it into the search box at the top of the UI):

    ```bash
    oc logs deployment/greeting | grep '"path":"/greeting"' | grep -v '"duration_ms":0' | tail -3
    ```

## Cleanup

```bash
oc delete pod load
helm uninstall greeting
oc delete project observability-lab
```
