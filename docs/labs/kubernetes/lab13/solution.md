---
tags:
  - Solution
  - Observability
---

# Lab 13 Solution - Observability

## Part 1: PromQL queries

```promql
# Request rate per status code
sum by (code) (rate(greeting_requests_total[5m]))

# Error ratio
sum(rate(greeting_requests_total{code=~"5.."}[5m])) / sum(rate(greeting_requests_total[5m]))

# 95th percentile latency of /greeting
histogram_quantile(0.95, sum by (le) (rate(greeting_request_duration_seconds_bucket{path="/greeting"}[5m])))
```

With the load generator running, the error ratio is about **0.33**: one of every three requests goes to `/fail`.

The p95 latency of `/greeting` comes out around **0.47 s**, even though the slow requests actually take 300 ms. Prometheus histograms only record which **bucket** each request falls in (the defaults are ..., 0.1, 0.25, 0.5, 1, ... seconds), and `histogram_quantile` interpolates *within* a bucket. The 300 ms requests all land in the 0.25–0.5 s bucket, so the estimate lands near the top of it. In real services, choose bucket boundaries around your latency objective, for example a bucket at 0.3 s if your target is "95% under 300 ms".

!!! tip
    Use `rate()` on counters, never the raw value. Counters only go up and reset when a pod restarts. `rate()` turns them into "per second over the last N minutes" and handles resets.

## Part 2: Why a ratio and `for: 1m`?

- **A ratio, not a count:** 5 errors a minute is a disaster at 10 requests a minute and noise at 10,000. A ratio scales with traffic and matches what users feel.
- **`for: 1m`:** the condition must hold for a minute before the alert fires. That filters out one-off spikes, such as a single failed deploy step, so on-call engineers only get paged for sustained problems.

Expected progression: `Inactive` → `Pending` (condition true, waiting out `for`) → `Firing`. When the load stops, the alert resolves on its own.

## Part 3: The slow trace

A slow request has three spans:

```text
GET /greeting          ~301 ms   (server span, created by the otelhttp middleware)
├── slow dependency    ~300 ms   delay_ms=300
└── compose greeting     ~0 ms   greeting.name=slow
```

The `slow dependency` span accounts for almost all the time. In a real system, this is how you spot a slow downstream database or API call without guessing.

## Part 4: Log-to-trace correlation

```json
{"time":"...","level":"INFO","msg":"request","method":"GET","path":"/greeting","code":200,"duration_ms":301,"trace_id":"4bf92f3577b34da6a3ce929d0e0e4736"}
```

Paste the `trace_id` into Jaeger's search box to open exactly that request's trace. In production, OpenShift's console can link logs and traces for you when OpenShift Logging and distributed tracing are installed.
