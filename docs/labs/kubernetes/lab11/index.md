---
tags:
  - Lab
  - Networking
  - OpenShift only
  - Intermediate
---

# Lab 11 - Routes & Ingress

<span class="lab-badge">30 min</span> <span class="lab-badge">Intermediate</span> <span class="lab-badge">OpenShift only</span>

## Problem

The Rebel Alliance needs its new web portal reachable from outside the cluster. Services only give you an address inside the cluster, so you'll publish the app in two ways:

- An OpenShift **Route**, OpenShift's native way to expose HTTP(S) apps through the cluster's router
- A standard Kubernetes **Ingress**, which OpenShift turns into a Route for you

!!! info "Requires OpenShift"
    This lab uses the `Route` API, which exists only on OpenShift. On plain Kubernetes, the same ideas apply to Ingress or [Gateway API](https://gateway-api.sigs.k8s.io/) resources served by an ingress or gateway controller.

## Setup

```bash
oc new-project lab11
oc create deployment web --image=quay.io/nginx/nginx-unprivileged:1.29 --port=8080
oc expose deployment web --port=8080
oc rollout status deployment/web
```

## Tasks

1. **Create an HTTP Route** named `web` for the `web` Service, and open the app with `curl` using the Route's hostname.
2. **Create a secure edge Route** named `web-secure`. TLS terminates at the router, and plain HTTP requests are redirected to HTTPS.
3. **Create an Ingress** named `web-ingress` that sends requests for the host `web-ingress-lab11.<apps-domain>` to the `web` Service on port `8080`. Then find the Route that OpenShift generated from it.

!!! tip "Finding the apps domain"
    Every Route hostname ends in the cluster's apps domain, for example `apps-crc.testing` on OpenShift Local. Once the `web` Route exists, you can read the domain from it:

    ```bash
    APPS_DOMAIN=$(oc get route web -o jsonpath='{.spec.host}' | cut -d. -f2-)
    echo "${APPS_DOMAIN}"
    ```

## Hints

- `oc expose service` creates an HTTP Route with a generated hostname.
- `oc create route edge --help` shows how to create a TLS edge Route, including `--insecure-policy`.
- An Ingress needs `spec.rules[].host` and a `backend.service` with a `name` and `port.number`.

## Verification

```bash
oc get routes
```

You should see three Routes: `web`, `web-secure`, and one generated from the Ingress, named `web-ingress-xxxxx`.

```bash
# 1. HTTP Route
curl -s "http://$(oc get route web -o jsonpath='{.spec.host}')" | grep "<title>"

# 2. Edge Route: HTTP redirects (302) to HTTPS, and HTTPS serves the page
#    (-k skips certificate verification, since local clusters use a self-signed certificate)
curl -s -o /dev/null -w '%{http_code}\n' "http://$(oc get route web-secure -o jsonpath='{.spec.host}')"
curl -sk "https://$(oc get route web-secure -o jsonpath='{.spec.host}')" | grep "<title>"

# 3. Ingress
curl -s "http://web-ingress-lab11.${APPS_DOMAIN}" | grep "<title>"
```

Each `grep` prints `<title>Welcome to nginx!</title>`.

## Going further

Routes can split traffic between Services, which is handy for canary and A/B releases. Deploy a second version and send 20% of the traffic to it:

```bash
oc create deployment web-v2 --image=quay.io/nginx/nginx-unprivileged:1.28 --port=8080
oc expose deployment web-v2 --port=8080
oc set route-backends web web=80 web-v2=20
oc get route web
```

## Cleanup

```bash
oc delete project lab11
```
