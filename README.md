# IBM Cloud Native Bootcamp

Source for the [Cloud Native Bootcamp](https://ibm-cloud-architecture.github.io/cloud-native-bootcamp/) site: concepts and hands-on labs for containers, Kubernetes/OpenShift, Tekton and Argo CD.

## Technologies covered

- **Cloud native** fundamentals
- **Containers**: Podman/Docker, image registries (Quay.io, OpenShift internal registry)
- **Orchestration**: Kubernetes and Red Hat OpenShift
- **CI/CD**: Tekton (OpenShift Pipelines) and Argo CD (OpenShift GitOps)

## Running the site locally

Requires Python 3.10 or later (3.9 works but is end-of-life).

```bash
git clone https://github.com/ibm-cloud-architecture/cloud-native-bootcamp.git
cd cloud-native-bootcamp
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
mkdocs serve            # http://127.0.0.1:8000 with live reload
mkdocs build --strict   # the same check CI runs on every pull request
```

### Using a container instead

The `dev/` scripts use Docker, or Podman if Docker isn't installed:

```bash
npm run dev:build   # build the dev image
npm run dev         # serve on http://localhost:8000
npm run test        # strict build inside the container
npm run dev:stop
```

## Publishing

Pushing to `main` builds the site with `mkdocs build --strict` and deploys it to GitHub Pages (`.github/workflows/docs.yml`). Pull requests run the same build plus an external link check.
