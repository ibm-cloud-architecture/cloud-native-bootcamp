# Sample application

`greeting/` is the small Go web service used throughout the bootcamp labs:

- **Containers Lab**: build, run and push it with Podman
- **Image Registry Lab**: build it inside OpenShift
- **Tekton Lab**: build and deploy it with OpenShift Pipelines
- **Argo CD Lab**: deploy it with GitOps from `gitops/`

It listens on port 8080 and serves:

| Path | Response |
| --- | --- |
| `/greeting?name=<name>` | `{"message":"<GREETING env var or default>","name":"<name>"}` |
| `/healthz` | `ok` |

Build and run locally:

```bash
podman build -t greeting:dev sample-app/greeting
podman run --rm -p 8080:8080 greeting:dev
```

## GitOps manifests

`gitops/` holds the Deployment, Service and Route that the Argo CD lab syncs. The image is built and published by `.github/workflows/sample-app.yml`.
