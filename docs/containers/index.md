# What are Containers?

You wanted to run your application on different computing environments. It may be your laptop, test environment, staging environment or production environment.

So, when you run it on these different environments, will your application work reliably?

What if some underlying software changes? What if the security policies are different? Or something else changes?

To solve these problems, we need Containers.

## Containers

Containers are a standard way to package an application and all its dependencies so that it can be moved between environments and run without change. They work by hiding the differences between applications inside the container so that everything outside the container can be standardized.

For example, Docker created a standard way to create images for Linux Containers.

<iframe width="1206" height="678" src="https://www.youtube.com/embed/0qotVMX-J5s" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Presentations

[Container Basics :fontawesome-regular-file-pdf:](./materials/02-Containers-Basics.pdf){ .md-button }

## Why Containers?

- **Run anywhere** - Containers run consistently on any platform that supports a container runtime
- **Lightweight** - Share the host OS kernel, using fewer resources than virtual machines
- **Fast startup** - Start in seconds rather than minutes
- **Isolation** - Applications run in isolated environments without interfering with each other
- **Scalable** - Easily scale up or down based on demand

<iframe width="640" height="480" src="https://www.youtube.com/embed/muTkqVewJMI" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## How Containers Work

Containers leverage Linux kernel features to provide isolation and resource management:

### Linux Namespaces

Namespaces provide isolation for system resources, making each container appear to have its own:

- **PID namespace** - Isolated process tree
- **Network namespace** - Isolated network stack (interfaces, routing tables, firewall rules)
- **Mount namespace** - Isolated filesystem mount points
- **User namespace** - Isolated user and group IDs
- **UTS namespace** - Isolated hostname and domain name

### Control Groups (cgroups)

Cgroups limit and account for resource usage:

- CPU time and cores
- Memory limits
- Disk I/O bandwidth
- Network bandwidth

### Union Filesystems

Container images use layered filesystems (like OverlayFS) that allow:

- Efficient storage through shared base layers
- Copy-on-write for container modifications
- Fast image distribution

## Container Runtimes and Standards

The container ecosystem has evolved around open standards managed by the **Open Container Initiative (OCI)**, a Linux Foundation project.

### OCI Specifications

| Specification | Purpose |
| ------------- | ------- |
| **Runtime Spec** | Defines how to run a container (filesystem bundle, lifecycle, configuration) |
| **Image Spec** | Defines container image format (layers, manifests, configuration) |
| **Distribution Spec** | Defines how images are distributed via registries |

### Container Runtimes

**Low-level runtimes** (OCI-compliant):

- **runc** - The reference implementation, created by Docker and donated to OCI
- **crun** - A fast, lightweight runtime written in C (used by Podman)
- **youki** - A runtime written in Rust for improved safety

**High-level runtimes**:

- **containerd** - Industry standard runtime used by Docker and Kubernetes, manages the complete container lifecycle
- **CRI-O** - Lightweight runtime built specifically for Kubernetes, implements the Container Runtime Interface (CRI)

### Container Engines

Container engines provide user-friendly tools for building, running, and managing containers:

| Engine | Description |
| ------ | ----------- |
| **Docker** | The most widely adopted container platform, includes Docker Engine, CLI, and Desktop |
| **Podman** | Daemonless, rootless container engine, drop-in replacement for Docker CLI |
| **Buildah** | Specialized tool for building OCI-compliant container images |
| **nerdctl** | Docker-compatible CLI for containerd |

!!! tip "Docker vs Podman"
    Both Docker and Podman use OCI-compliant images and can run the same containers. Key differences:

    - **Docker** uses a daemon (dockerd) that runs as root
    - **Podman** is daemonless and runs rootless by default (more secure)
    - Commands are nearly identical: `docker run` = `podman run`

## Docker

Docker is the most popular containerization platform, providing tools to develop, deploy, and run applications inside containers.

- Open source project (Moby)
- Available on Linux, macOS, and Windows
- Extensive ecosystem and community

<iframe width="640" height="480" src="https://www.youtube.com/embed/wFNWl-QwPfc" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

### Docker Architecture

```text
┌─────────────────────────────────────────────────────────┐
│                      Docker Client                       │
│                  (docker CLI commands)                   │
└─────────────────────────┬───────────────────────────────┘
                          │ REST API
┌─────────────────────────▼───────────────────────────────┐
│                     Docker Daemon                        │
│                       (dockerd)                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │   Images    │  │ Containers  │  │    Networks     │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│                      containerd                          │
│              (container runtime manager)                 │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│                         runc                             │
│                 (OCI container runtime)                  │
└─────────────────────────────────────────────────────────┘
```

### Docker Image

A read-only template containing instructions for creating a container. Images are built from a `Dockerfile` and stored in registries.

Images are composed of **layers**:

- Each instruction in a Dockerfile creates a new layer
- Layers are cached and reused across images
- Only changed layers need to be transferred when pulling/pushing

### Dockerfile

A text file containing instructions to build a Docker image.

```dockerfile
# Base image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy dependency files first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Create non-root user for security
RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -s /bin/sh -D appuser
USER appuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/health || exit 1

# Start command
CMD ["node", "server.js"]
```

### Multi-stage Builds

Multi-stage builds reduce image size by separating build and runtime environments:

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
# Copy only production dependencies and built files
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
USER node
CMD ["node", "dist/server.js"]
```

### Docker Container

A runnable instance of an image. Containers are isolated from each other and the host system.

```bash
# Run a container
docker run -d --name myapp -p 8080:3000 myimage:latest

# View running containers
docker ps

# View logs
docker logs myapp

# Execute command in running container
docker exec -it myapp /bin/sh

# Stop and remove
docker stop myapp && docker rm myapp
```

### Docker Registry

A service that stores and distributes container images:

- **Docker Hub** - Public registry with official and community images ([hub.docker.com](https://hub.docker.com))
- **Red Hat Quay** - Enterprise registry with security scanning
- **IBM Cloud Container Registry** - IBM's managed registry service
- **GitHub Container Registry** - GitHub's package registry for containers
- **Amazon ECR / Google GCR / Azure ACR** - Cloud provider registries

<iframe width="640" height="480" src="https://www.youtube.com/embed/CPJLKqvR8II" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Dockerfile Best Practices

### 1. Use Minimal Base Images

Choose the smallest base image that meets your needs:

| Image Type | Size | Use Case |
| ---------- | ---- | -------- |
| `scratch` | 0 MB | Statically compiled binaries (Go, Rust) |
| `alpine` | ~5 MB | General purpose, includes shell |
| `distroless` | ~20 MB | No shell, package manager, or unnecessary tools |
| `slim` variants | ~50-100 MB | Reduced versions of full images |

```dockerfile
# Good - minimal image
FROM node:20-alpine

# Avoid - full image with unnecessary tools
FROM node:20
```

### 2. Run as Non-root User

Never run containers as root in production:

```dockerfile
# Create and switch to non-root user
RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -s /bin/sh -D appuser
USER appuser
```

### 3. Optimize Layer Caching

Order instructions from least to most frequently changing:

```dockerfile
# Good - dependencies cached separately from code
COPY package*.json ./
RUN npm ci
COPY . .

# Bad - cache invalidated on any code change
COPY . .
RUN npm ci
```

### 4. Use .dockerignore

Exclude unnecessary files from the build context:

```text
# .dockerignore
node_modules
.git
.env
*.log
Dockerfile
.dockerignore
```

### 5. Pin Versions

Always pin base image and dependency versions:

```dockerfile
# Good - pinned version
FROM node:20.10.0-alpine3.19

# Avoid - unpredictable updates
FROM node:latest
```

### 6. Minimize Layers

Combine related commands to reduce layers:

```dockerfile
# Good - single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Bad - multiple layers, cached apt lists
RUN apt-get update
RUN apt-get install -y curl
```

### 7. Add Health Checks

Enable orchestrators to monitor container health:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

## Container Security

### Image Security

- **Scan images for vulnerabilities** - Use tools like Trivy, Grype, or Snyk
- **Sign images** - Use Cosign/Sigstore for image verification
- **Use trusted base images** - Prefer official images from verified publishers
- **Keep images updated** - Regularly rebuild with security patches

```bash
# Scan image with Trivy
trivy image myapp:latest

# Sign image with Cosign
cosign sign myregistry.io/myapp:latest
```

### Runtime Security

- **Run as non-root** - Never run containers as root
- **Read-only filesystem** - Use `--read-only` flag when possible
- **Drop capabilities** - Remove unnecessary Linux capabilities
- **Resource limits** - Set CPU and memory limits

```bash
# Secure container run
docker run -d \
  --read-only \
  --user 1001:1001 \
  --cap-drop ALL \
  --memory 512m \
  --cpus 0.5 \
  myapp:latest
```

### Supply Chain Security

- **Generate SBOMs** - Create Software Bill of Materials for images
- **Verify signatures** - Validate image authenticity before deployment
- **Use private registries** - Control access to your container images

```bash
# Generate SBOM with Syft
syft myapp:latest -o spdx-json > sbom.json
```

## References

- [Docker Documentation](https://docs.docker.com/)
- [Podman Documentation](https://docs.podman.io/)
- [Open Container Initiative (OCI)](https://opencontainers.org/)
- [Cloud Native Computing Foundation (CNCF)](https://www.cncf.io/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Container Security Guide - NIST](https://csrc.nist.gov/publications/detail/sp/800-190/final)
