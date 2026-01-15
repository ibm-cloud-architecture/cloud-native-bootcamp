# What are Image Registries

A registry is a repository used to store and access container images. Container registries can support container-based application development, often as part of DevOps processes.

Container registries save developers valuable time in the creation and delivery of cloud-native applications, acting as the intermediary for sharing container images between systems. They essentially act as a place for developers to store container images and share them out via a process of uploading (pushing) to the registry and downloading (pulling) into another system, like a Kubernetes cluster.

## Popular Container Registries

| Registry | Description | Use Case |
| -------- | ----------- | -------- |
| **Docker Hub** | The largest public registry with official and community images | Public images, getting started |
| **Red Hat Quay** | Enterprise registry with security scanning and geo-replication | Enterprise, OpenShift environments |
| **IBM Cloud Registry** | IBM's managed registry with vulnerability scanning | IBM Cloud deployments |
| **GitHub Container Registry** | Integrated with GitHub for seamless CI/CD | GitHub-based projects |
| **Amazon ECR** | AWS-native registry with IAM integration | AWS deployments |
| **Google Artifact Registry** | GCP-native registry supporting multiple artifact types | GCP deployments |
| **Azure Container Registry** | Azure-native with geo-replication and tasks | Azure deployments |
| **Harbor** | Open-source enterprise registry with RBAC and scanning | Self-hosted enterprise |

[Learn More :fontawesome-solid-globe:](https://www.redhat.com/en/topics/cloud-native-apps/what-is-a-container-registry){ .md-button target="_blank"}

## Registry Concepts

### Image Naming Convention

Container images follow a standard naming format:

```text
[registry-host/][namespace/]repository[:tag|@digest]
```

**Examples:**

| Image Reference | Description |
| --------------- | ----------- |
| `nginx` | Docker Hub official image, latest tag implied |
| `nginx:1.25` | Docker Hub official image with specific tag |
| `myuser/myapp:v1.0` | Docker Hub user namespace |
| `quay.io/myorg/myapp:latest` | Quay.io registry |
| `us.icr.io/mynamespace/myapp:v2` | IBM Cloud Registry |
| `ghcr.io/owner/repo:sha-abc123` | GitHub Container Registry |

### Tags vs Digests

**Tags** are mutable labels that can be moved to different image versions:

```bash
myapp:latest    # Can change over time
myapp:v1.0      # Semantic version
myapp:dev       # Environment-specific
```

**Digests** are immutable content-addressable identifiers:

```bash
myapp@sha256:abc123...  # Always refers to exact same image
```

!!! warning "Production Best Practice"
    Use digests or specific version tags in production. Avoid `latest` as it can change unexpectedly.

### Image Layers and Caching

Images are composed of layers, each representing a Dockerfile instruction:

```text
┌─────────────────────────────┐
│  Application Code (Layer 4) │  ← Changes frequently
├─────────────────────────────┤
│  Dependencies (Layer 3)     │  ← Changes occasionally
├─────────────────────────────┤
│  Runtime (Layer 2)          │  ← Rarely changes
├─────────────────────────────┤
│  Base OS (Layer 1)          │  ← Rarely changes
└─────────────────────────────┘
```

Registries store layers efficiently:

- Layers are deduplicated across images
- Only changed layers are transferred during push/pull
- Base layers are shared between many images

## Registry Security

### Image Scanning

Most enterprise registries include vulnerability scanning:

- **Automatic scanning** on push
- **CVE database** integration
- **Severity ratings** (Critical, High, Medium, Low)
- **Policy enforcement** to block vulnerable images

```bash
# Scan locally with Trivy before pushing
trivy image myapp:latest

# Example output
myapp:latest (alpine 3.19.0)
Total: 2 (UNKNOWN: 0, LOW: 1, MEDIUM: 1, HIGH: 0, CRITICAL: 0)
```

### Image Signing

Verify image authenticity and integrity using signatures:

**Cosign (Sigstore)**

```bash
# Sign an image
cosign sign myregistry.io/myapp:v1.0

# Verify signature before pulling
cosign verify myregistry.io/myapp:v1.0
```

**Docker Content Trust (DCT)**

```bash
# Enable content trust
export DOCKER_CONTENT_TRUST=1

# Push signed image
docker push myregistry.io/myapp:v1.0
```

### Access Control

Registries provide various access control mechanisms:

| Mechanism | Description |
| --------- | ----------- |
| **Authentication** | Username/password, tokens, or SSO |
| **Authorization** | Role-based access (read, write, admin) |
| **Namespaces** | Organizational separation of images |
| **Private repositories** | Restrict access to authorized users |
| **Robot accounts** | Service accounts for CI/CD automation |

### Software Bill of Materials (SBOM)

Generate and attach SBOMs to track image contents:

```bash
# Generate SBOM with Syft
syft myapp:latest -o spdx-json > sbom.json

# Attach SBOM to image with Cosign
cosign attach sbom --sbom sbom.json myregistry.io/myapp:v1.0
```

## Registry Best Practices

### Image Tagging Strategy

Use a consistent tagging strategy for your images:

| Tag Type | Example | Use Case |
| -------- | ------- | -------- |
| Semantic version | `v1.2.3` | Release versions |
| Git SHA | `sha-abc1234` | Traceability to source |
| Build number | `build-456` | CI/CD tracking |
| Environment | `staging`, `prod` | Environment-specific |
| Date | `2025-01-15` | Time-based releases |

**Recommended approach:**

```bash
# Tag with both version and git SHA
docker tag myapp:latest myregistry.io/myapp:v1.2.3
docker tag myapp:latest myregistry.io/myapp:sha-$(git rev-parse --short HEAD)
```

### Image Lifecycle Management

Keep your registry clean and costs manageable:

- **Retention policies** - Automatically delete old images
- **Immutable tags** - Prevent tag overwrites for release versions
- **Garbage collection** - Remove unreferenced layers

```bash
# IBM Cloud Registry - delete old images
ibmcloud cr retention-policy-set --images 10 mynamespace

# Quay - set up auto-pruning in repository settings
```

### CI/CD Integration

Automate image building and pushing in your pipeline:

```yaml
# Example GitHub Actions workflow
name: Build and Push
on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Login to Registry
        run: echo "${{ secrets.REGISTRY_PASSWORD }}" | docker login quay.io -u ${{ secrets.REGISTRY_USER }} --password-stdin

      - name: Build and Push
        run: |
          docker build -t quay.io/myorg/myapp:${{ github.sha }} .
          docker push quay.io/myorg/myapp:${{ github.sha }}

      - name: Scan Image
        run: trivy image quay.io/myorg/myapp:${{ github.sha }}
```

### Multi-Architecture Images

Build images for multiple platforms (amd64, arm64):

```bash
# Create and use buildx builder
docker buildx create --name mybuilder --use

# Build multi-arch image
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t myregistry.io/myapp:v1.0 \
  --push .
```

## Next Steps

Ready to start working with registries? Check out the hands-on tutorials:

[Registry Tutorials :fontawesome-solid-arrow-right:](registry-tutorials.md){ .md-button .md-button--primary }

The tutorials cover step-by-step instructions for:

- Docker Hub
- Red Hat Quay
- IBM Cloud Container Registry
