# Lab 11 Solution - Routes & Ingress

## 1. HTTP Route

```bash
oc expose service web
oc get route web
curl -s "http://$(oc get route web -o jsonpath='{.spec.host}')" | grep "<title>"
```

The equivalent manifest:

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: web
spec:
  to:
    kind: Service
    name: web
  port:
    targetPort: 8080
```

When `spec.host` is left empty, OpenShift generates `<route-name>-<project>.<apps-domain>`.

## 2. Secure edge Route

```bash
oc create route edge web-secure --service=web --insecure-policy=Redirect
curl -s -o /dev/null -w '%{http_code}\n' "http://$(oc get route web-secure -o jsonpath='{.spec.host}')"
curl -sk "https://$(oc get route web-secure -o jsonpath='{.spec.host}')" | grep "<title>"
```

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: web-secure
spec:
  to:
    kind: Service
    name: web
  port:
    targetPort: 8080
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
```

| TLS termination | Where TLS ends | Use when |
| --- | --- | --- |
| `edge` | At the router. Traffic to the pod is plain HTTP. | The most common choice. The router holds the certificate. |
| `passthrough` | At the pod. The router forwards encrypted traffic untouched. | The app must handle TLS itself, for example for mutual TLS. |
| `reencrypt` | At the router, which opens a new TLS connection to the pod | TLS is needed all the way to the pod, but the router still inspects HTTP. |

## 3. Ingress

```bash
APPS_DOMAIN=$(oc get route web -o jsonpath='{.spec.host}' | cut -d. -f2-)

oc apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
spec:
  rules:
    - host: web-ingress-lab11.${APPS_DOMAIN}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web
                port:
                  number: 8080
EOF

oc get ingress web-ingress
oc get routes
curl -s "http://web-ingress-lab11.${APPS_DOMAIN}" | grep "<title>"
```

OpenShift's ingress controller watches `Ingress` objects and creates a matching Route, named `web-ingress-<random>` and owned by the Ingress. Delete the Ingress and the Route goes with it.

!!! note "Route or Ingress?"
    Use **Routes** when you target only OpenShift and want features such as TLS re-encryption, passthrough or weighted backends. Use **Ingress** (or **Gateway API**, which OpenShift supports from 4.19) when manifests must also run on other Kubernetes distributions.
