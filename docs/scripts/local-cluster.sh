#!/usr/bin/env bash
# Cloud Native Bootcamp - local lab cluster
#
# Creates a local Kubernetes cluster with kind (on Docker or Podman) and,
# optionally, the add-ons the labs need. OpenShift-only features (Routes,
# OperatorHub, BuildConfigs, the web console) are not available here; see the
# Lab Environments page for which labs need OpenShift.
#
# Usage:
#   ./local-cluster.sh [--devops] [--monitoring] [--virtualization] [--openshift-like] [--all]
#   ./local-cluster.sh --delete
#
#   --devops          Tekton Pipelines + Triggers and Argo CD
#   --monitoring      Prometheus Operator and a Prometheus that scrapes ServiceMonitors in every namespace
#   --virtualization  KubeVirt (software emulation when /dev/kvm is not available)
#   --openshift-like  OpenShift restricted-v2 style defaults (random non-root UID, all capabilities
#                     dropped) for namespaces labelled openshift-like=true
#   --all             Everything above
#
# Requirements: kind, kubectl, and Docker or Podman. Give the Docker/Podman VM at least
# 4 CPUs and 8 GB of memory (12 GB with --virtualization).

set -euo pipefail

CLUSTER=${CLUSTER:-bootcamp}
DEVOPS=false MONITORING=false VIRT=false OCPLIKE=false

for arg in "$@"; do
  case "$arg" in
    --devops) DEVOPS=true ;;
    --monitoring) MONITORING=true ;;
    --virtualization) VIRT=true ;;
    --openshift-like) OCPLIKE=true ;;
    --all) DEVOPS=true MONITORING=true VIRT=true OCPLIKE=true ;;
    --delete) DELETE=true ;;
    -h|--help) sed -n '2,23p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg (see --help)"; exit 1 ;;
  esac
done

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# kind talks to Docker by default; fall back to Podman if Docker isn't installed
if ! command -v docker >/dev/null 2>&1 && command -v podman >/dev/null 2>&1; then
  export KIND_EXPERIMENTAL_PROVIDER=podman
fi
for tool in kind kubectl; do
  command -v "$tool" >/dev/null 2>&1 || { echo "Missing required tool: $tool"; exit 1; }
done

if [ "${DELETE:-false}" = true ]; then
  kind delete cluster --name "$CLUSTER"
  exit 0
fi

wait_deployments() { kubectl wait --for=condition=Available deployment --all -n "$1" --timeout="${2:-300s}"; }

log "Creating kind cluster '$CLUSTER'"
if kind get clusters 2>/dev/null | grep -qx "$CLUSTER"; then
  echo "Cluster already exists, reusing it."
else
  kind create cluster --name "$CLUSTER" --wait 180s --config - <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
EOF
fi
kubectl config use-context "kind-$CLUSTER" >/dev/null

log "Installing metrics-server (for kubectl top and autoscaling)"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml >/dev/null
kubectl -n kube-system patch deployment metrics-server --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' >/dev/null 2>&1 || true

if [ "$DEVOPS" = true ]; then
  log "Installing Tekton Pipelines and Triggers"
  kubectl apply -f https://infra.tekton.dev/tekton-releases/pipeline/latest/release.yaml >/dev/null
  wait_deployments tekton-pipelines
  kubectl apply -f https://infra.tekton.dev/tekton-releases/triggers/latest/release.yaml >/dev/null
  kubectl apply -f https://infra.tekton.dev/tekton-releases/triggers/latest/interceptors.yaml >/dev/null
  wait_deployments tekton-pipelines

  log "Installing Argo CD"
  kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f - >/dev/null
  kubectl apply -n argocd --server-side --force-conflicts \
    -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml >/dev/null
  wait_deployments argocd
fi

if [ "$MONITORING" = true ]; then
  log "Installing Prometheus Operator"
  kubectl apply --server-side --force-conflicts \
    -f https://github.com/prometheus-operator/prometheus-operator/releases/latest/download/bundle.yaml >/dev/null
  kubectl wait --for=condition=Available deployment/prometheus-operator -n default --timeout=300s
  kubectl wait --for=condition=Established crd/prometheuses.monitoring.coreos.com --timeout=120s >/dev/null

  log "Creating a Prometheus that scrapes ServiceMonitors and rules in every namespace"
  kubectl apply -f - >/dev/null <<'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: monitoring
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: bootcamp-prometheus
rules:
  - apiGroups: [""]
    resources: [nodes, nodes/metrics, services, endpoints, pods, configmaps]
    verbs: [get, list, watch]
  - apiGroups: [discovery.k8s.io]
    resources: [endpointslices]
    verbs: [get, list, watch]
  - nonResourceURLs: [/metrics]
    verbs: [get]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: bootcamp-prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: bootcamp-prometheus
subjects:
  - kind: ServiceAccount
    name: prometheus
    namespace: monitoring
---
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus
  namespace: monitoring
spec:
  serviceAccountName: prometheus
  scrapeInterval: 15s
  evaluationInterval: 15s
  serviceMonitorNamespaceSelector: {}
  serviceMonitorSelector: {}
  podMonitorNamespaceSelector: {}
  podMonitorSelector: {}
  ruleNamespaceSelector: {}
  ruleSelector: {}
EOF
  # The operator creates the StatefulSet a few seconds after the Prometheus resource
  for _ in $(seq 1 60); do
    kubectl -n monitoring get statefulset prometheus-prometheus >/dev/null 2>&1 && break
    sleep 2
  done
  kubectl -n monitoring rollout status statefulset/prometheus-prometheus --timeout=300s
fi

if [ "$VIRT" = true ]; then
  log "Installing KubeVirt"
  KV_VERSION=$(curl -fsSL https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
  kubectl apply -f "https://github.com/kubevirt/kubevirt/releases/download/${KV_VERSION}/kubevirt-operator.yaml" >/dev/null
  kubectl apply -f "https://github.com/kubevirt/kubevirt/releases/download/${KV_VERSION}/kubevirt-cr.yaml" >/dev/null
  # kind nodes rarely have hardware virtualization; fall back to (slower) software emulation
  if ! docker exec "${CLUSTER}-worker" test -e /dev/kvm >/dev/null 2>&1 \
     && ! podman exec "${CLUSTER}-worker" test -e /dev/kvm >/dev/null 2>&1; then
    echo "No /dev/kvm on the nodes: enabling KubeVirt software emulation (VMs will be slow)."
    kubectl -n kubevirt patch kubevirt kubevirt --type=merge \
      -p '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true}}}}' >/dev/null
  fi
  kubectl -n kubevirt wait kv kubevirt --for condition=Available --timeout=600s
fi

if [ "$OCPLIKE" = true ]; then
  log "Adding OpenShift-style security defaults for namespaces labelled openshift-like=true"
  kubectl apply -f - >/dev/null <<'EOF'
# Emulates OpenShift's restricted-v2 SCC: random non-root UID in group 0,
# no privilege escalation, all capabilities dropped, RuntimeDefault seccomp.
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingAdmissionPolicy
metadata:
  name: openshift-restricted-v2
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE"]
        resources: ["pods"]
  failurePolicy: Fail
  reinvocationPolicy: IfNeeded
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: >
          Object{
            spec: Object.spec{
              securityContext: Object.spec.securityContext{
                runAsNonRoot: true,
                runAsUser: 60123,
                runAsGroup: 0,
                fsGroup: 60123,
                seccompProfile: Object.spec.securityContext.seccompProfile{type: "RuntimeDefault"}
              },
              containers: object.spec.containers.map(c, Object.spec.containers{
                name: c.name,
                securityContext: Object.spec.containers.securityContext{allowPrivilegeEscalation: false}
              })
            }
          }
    - patchType: JSONPatch
      jsonPatch:
        expression: >
          object.spec.containers.map(c, JSONPatch{
            op: "add",
            path: "/spec/containers/" + string(object.spec.containers.indexOf(c)) + "/securityContext/capabilities",
            value: Object.spec.containers.securityContext.capabilities{drop: ["ALL"]}
          })
    - patchType: JSONPatch
      jsonPatch:
        expression: >
          has(object.spec.initContainers) ? object.spec.initContainers.map(c, JSONPatch{
            op: "add",
            path: "/spec/initContainers/" + string(object.spec.initContainers.indexOf(c)) + "/securityContext",
            value: Object.spec.initContainers.securityContext{
              allowPrivilegeEscalation: false,
              capabilities: Object.spec.initContainers.securityContext.capabilities{drop: ["ALL"]}
            }
          }) : []
---
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingAdmissionPolicyBinding
metadata:
  name: openshift-restricted-v2
spec:
  policyName: openshift-restricted-v2
  matchResources:
    namespaceSelector:
      matchLabels:
        openshift-like: "true"
EOF
  echo "Create an OpenShift-like namespace with:"
  echo "  kubectl create namespace lab1"
  echo "  kubectl label namespace lab1 openshift-like=true pod-security.kubernetes.io/enforce=restricted"
fi

log "Done"
kubectl get nodes
cat <<EOF

Cluster '$CLUSTER' is ready. Use kubectl (or oc) against context kind-$CLUSTER.
Delete it when you're finished:  $0 --delete
EOF
