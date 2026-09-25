#!/usr/bin/env bash
# Cloud Native Bootcamp - workstation check.
# Reports which tools are installed and where to get the missing ones.

ok=$'\xE2\x9C\x85'
missing=$'\xE2\x9D\x8C'
optional=$'\xE2\x9E\x96'
failures=0

# check <command> <display name> <required|optional> <install URL> <version command...>
check() {
  local cmd=$1 name=$2 level=$3 url=$4
  shift 4
  if command -v "$cmd" >/dev/null 2>&1; then
    local version
    version=$("$@" 2>/dev/null | head -n 1)
    printf '%s %-24s %s\n' "$ok" "$name" "$version"
  elif [ "$level" = "required" ]; then
    printf '%s %-24s not found - install from %s\n' "$missing" "$name" "$url"
    failures=$((failures + 1))
  else
    printf '%s %-24s not found (optional) - %s\n' "$optional" "$name" "$url"
  fi
}

echo "Cloud Native Bootcamp - system check"
echo

# A container engine: Podman preferred, Docker accepted
if command -v podman >/dev/null 2>&1; then
  check podman "Podman" required "https://podman.io/docs/installation" podman --version
else
  check docker "Docker (or Podman)" required "https://podman.io/docs/installation" docker --version
fi

check git    "Git"                   required "https://git-scm.com/downloads"                              git --version
check oc     "OpenShift CLI (oc)"    required "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/" oc version --client
check tkn    "Tekton CLI (tkn)"      optional "https://tekton.dev/docs/cli/"                               tkn version --component client
check argocd "Argo CD CLI (argocd)"  optional "https://argo-cd.readthedocs.io/en/stable/cli_installation/" argocd version --client --short
check crc    "OpenShift Local (crc)" optional "https://developers.redhat.com/products/openshift-local/overview" crc version
check kubectl "kubectl"              optional "https://kubernetes.io/docs/tasks/tools/"                    kubectl version --client

echo
if command -v oc >/dev/null 2>&1 && oc whoami >/dev/null 2>&1; then
  printf '%s Logged in to %s as %s\n' "$ok" "$(oc whoami --show-server)" "$(oc whoami)"
else
  printf '%s Not logged in to a cluster yet (see "Get a cluster" on the Prerequisites page)\n' "$optional"
fi

echo
if [ "$failures" -eq 0 ]; then
  echo "All required tools are installed."
else
  echo "$failures required tool(s) missing."
  exit 1
fi
