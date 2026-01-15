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

## Docker Hub Tutorial

Docker Hub is the default registry for Docker and contains millions of public images.

=== "Podman"

    **1. Search for images**

    ```bash
    podman search docker.io/nginx
    ```

    **2. Pull an image**

    ```bash
    podman pull docker.io/library/nginx:1.25-alpine
    ```

    **3. Login to Docker Hub**

    ```bash
    podman login docker.io
    ```
    Enter your Docker Hub username and password.

    **4. Tag your image**

    ```bash
    podman tag myapp:latest docker.io/yourusername/myapp:v1.0
    ```

    **5. Push to Docker Hub**

    ```bash
    podman push docker.io/yourusername/myapp:v1.0
    ```

    [View on Docker Hub :fontawesome-brands-docker:](https://hub.docker.com/){ .md-button target="_blank"}

=== "Docker"

    **1. Search for images**

    ```bash
    docker search nginx
    ```

    **2. Pull an image**

    ```bash
    docker pull nginx:1.25-alpine
    ```

    **3. Login to Docker Hub**

    ```bash
    docker login
    ```
    Enter your Docker Hub username and password.

    **4. Tag your image**

    ```bash
    docker tag myapp:latest yourusername/myapp:v1.0
    ```

    **5. Push to Docker Hub**

    ```bash
    docker push yourusername/myapp:v1.0
    ```

    [View on Docker Hub :fontawesome-brands-docker:](https://hub.docker.com/){ .md-button target="_blank"}

## Quay Tutorial

Red Hat Quay provides enterprise features like vulnerability scanning, geo-replication, and detailed access controls.

=== "Podman"

    Make sure you have Podman Desktop installed and up and running.

    Here's how to find a list of publicly available container images on DockerHub.

    ```bash title="Find Container Image"
    podman search docker.io/busybox
    ```

    ```bash title="Output:"
    NAME                                         DESCRIPTION
    docker.io/library/busybox                    Busybox base image.
    docker.io/rancher/busybox
    docker.io/openebs/busybox-client
    ...
    ```

    We can create a _busybox_ container image based off of the _busybox_ base image you see listed in the output above.

    ```bash title="Create Image"
    podman run -it docker.io/library/busybox
    ```

    The _-it_ flag allows you to run the image in interactive mode. Interactive mode in Podman allows you to run a shell in a container and interact with it. However, you'll see that running small containers like this one don't have much to play around with in the interactive mode. To exit out of the interactive mode:

    ```bash title="Exit Interactive mode"
    exit
    ```

    You can also share images in a public registry so that others can use and review them. Here's how to push your image up to quay.io.

    ```bash title="Login to quay.io"
    podman login quay.io
    ```
    Enter in the following info:

    ```text
    Username: your_username
    Password: your_password
    ```

    Next, tag the image so that you can push it and find it in your account.

    ```bash title="Tag Image"
    podman tag <image_name> quay.io/your_username/image_registry_name
    ```

    Make sure to replace "image_name" with the name of the image you want to push up to quay.
    Replace "user_name" with your quay.io username.
    Replace "image_registry_name" with what you want the image to be named/labeled as in quay.

    Once the image is tagged, you can push it up to quay.

    ```bash title="Push Image"
    podman push quay.io/your_username/image_registry_name
    ```

    Your repository has now been pushed to Quay Container Registry!

    To view your repository, click on the button below:

    [Repositories](https://quay.io/repository/){ .md-button target="_blank"}

=== "Docker"

    Make sure you have Docker Desktop installed and up and running.

    ```bash title="Login to Quay"
    docker login quay.io
    Username: your_username
    Password: your_password
    ```

    First we'll create a container with a single new file based off of the busybox base image:

    ```bash title="Create a new container"
    docker run busybox echo "fun" > newfile
    ```

    The container will immediately terminate, so we'll use the command below to list it:

    ```bash
    docker ps -l
    ```

    The next step is to commit the container to an image and then tag that image with a relevant name so it can be saved to a repository.

    Replace "container_id" with your container id from the previous command.

    ```bash title="Create a new image"
    docker commit container_id quay.io/your_username/repository_name
    ```

    Be sure to replace "your_username" with your quay.io username and "repository_name" with a unique name for your repository.

    Now that we've tagged our image with a repository name, we can push the repository to Quay Container Registry:

    ```bash title="Push the image to Quay"
    docker push quay.io/your_username/repository_name
    ```

    Your repository has now been pushed to Quay Container Registry!

    To view your repository, click on the button below:

    [Repositories](https://quay.io/repository/){ .md-button target="_blank"}

## IBM Cloud Registry Tutorial

IBM Cloud Container Registry provides a multi-tenant, highly available, and scalable private image registry.

=== "Podman"

    **1. Install the Container Registry CLI**

    Before you begin, you need to install the IBM Cloud CLI so that you can run the IBM Cloud ***ibmcloud*** commands.

    ```bash title="Install the container-registry CLI"
    ibmcloud plugin install container-registry
    ```

    **2. Set up a namespace**

    Then, you need to create a namespace. The namespace is created in the resource group that you specify so that you can configure access to resources within the namespace at the resource group level. If you don't specify a resource group, then the default is used.

    ```bash title="Log in to IBM Cloud"
    ibmcloud login
    ```

    ```bash title="Create namespace"
    ibmcloud cr namespace-add <my_namespace>
    ```

    Make sure to replace <my_namespace\> with your preferred namespace.

    If you want to create the namespace in a specific resource group, use the following code **before** creating the namespace.

    ```bash title="Specify a resource group"
    ibmcloud target -g <resource_group>
    ```

    Replace <resource_group\> with the resource group you want to create the namespace in.

    To validate the namespace was created, run the following command.

    ```bash title="Validate namespace is created"
    ibmcloud cr namespace-list -v
    ```

    **3. Pull images from a registry to your local computer**

    Next, you can pull images from IBM Cloud Registry to your local computer. Make sure [Podman](https://podman.io/docs/installation){target="_blank"} is installed and up and running.

    ```bash title="Pull image to local computer"
    podman pull <source_image>:<tag>
    ```

    Replace <source_image\> with the repository of the image and <tag\> with the tag of the image that you want to use.

    Below is an example where <source_image\> is "hello-world" and <tag\> is "latest".

    ```bash
    podman pull hello-world:latest
    ```

    **4. Tag the image**

    Tags are used as an optional identifier to specify a particular version of an image.

    ```bash title="Tag image"
    podman tag <source_image>:<tag> <region>.icr.io/<my_namespace>/<new_image_repo>:<new_tag>
    ```

    Replace <source_image\> with the repository of the image, <tag\> with the tag of your local image that you previously pulled, <region\> with the name of your region, and <my_namespace\> with the namespace you created in step 2. You'll want to define the repository and tag of the image that you want to use in your namespace by replacing <new_image_repo\> and <new_tag\> respectively.

    Below is an example where <source_image\> is "hello-world", <tag\> is "latest", <region\> is "uk", <my_namespace\> is "namespace1", <new_image_repo\> is "hw_repo", and <new_tag\> is "1".

    ```bash
    podman tag hello-world:latest uk.icr.io/namespace1/hw_repo:1
    ```

    **5. Push images to your namespace**

    First, you'll need to log in to IBM Cloud Container Registry.

    ```bash title="Log in to ICR"
    ibmcloud cr login --client podman
    ```

    Once you've logged in, you can push the image up to your namespace in the registry.

    ```bash title="Push image to your namespace"
    podman push <region>.icr.io/<my_namespace>/<image_repo>:<tag>
    ```

    Replace <my_namespace\> with the namespace you created in step 2 and <image_repo\> and <tag\> with the repository and tag of the image you chose when you tagged the image in step 4.

    Below is an example where <region\> is "uk", <my_namespace\> is "namespace1", <image_repo\> is "hw_repo", and <tag\> is "1".

    ```bash
    podman push uk.icr.io/namespace1/hw_repo:1
    ```

    **6. Verify that the image was pushed**

    Verify that the image was pushed successfully by running the command below.

    ```bash
    ibmcloud cr image-list
    ```

    **7. Scan for vulnerabilities**

    IBM Cloud Registry includes Vulnerability Advisor to scan your images.

    ```bash title="Scan image for vulnerabilities"
    ibmcloud cr va <region>.icr.io/<my_namespace>/<image_repo>:<tag>
    ```

    You can also view your pushed images by clicking on the button below:

    [Images](https://cloud.ibm.com/containers/registry/images){ .md-button target="_blank"}

=== "Docker"

    **1. Install the Container Registry CLI**

    Before you begin, you need to install the IBM Cloud CLI so that you can run the IBM Cloud ***ibmcloud*** commands.

    ```bash title="Install the container-registry CLI"
    ibmcloud plugin install container-registry
    ```

    **2. Set up a namespace**

    Then, you need to create a namespace. The namespace is created in the resource group that you specify so that you can configure access to resources within the namespace at the resource group level. If you don't specify a resource group, then the default is used.

    ```bash title="Log in to IBM Cloud"
    ibmcloud login
    ```

    ```bash title="Create namespace"
    ibmcloud cr namespace-add <my_namespace>
    ```

    Make sure to replace <my_namespace\> with your preferred namespace.

    If you want to create the namespace in a specific resource group, use the following code **before** creating the namespace.

    ```bash title="Specify a resource group"
    ibmcloud target -g <resource_group>
    ```

    Replace <resource_group\> with the resource group you want to create the namespace in.

    To validate the namespace was created, run the following command.

    ```bash title="Validate namespace is created"
    ibmcloud cr namespace-list -v
    ```

    **3. Pull images from a registry to your local computer**

    Next, you can pull images from IBM Cloud Registry to your local computer. Make sure [Docker](https://www.docker.com/products/container-runtime/#/download){target="_blank"} is installed and up and running.

    ```bash title="Pull image to local computer"
    docker pull <source_image>:<tag>
    ```

    Replace <source_image\> with the repository of the image and <tag\> with the tag of the image that you want to use.

    Below is an example where <source_image\> is "hello-world" and <tag\> is "latest".

    ```bash
    docker pull hello-world:latest
    ```

    **4. Tag the image**

    Tags are used as an optional identifier to specify a particular version of an image.

    ```bash title="Tag image"
    docker tag <source_image>:<tag> <region>.icr.io/<my_namespace>/<new_image_repo>:<new_tag>
    ```

    Replace <source_image\> with the repository of the image, <tag\> with the tag of your local image that you previously pulled, <region\> with the name of your region, and <my_namespace\> with the namespace you created in step 2. You'll want to define the repository and tag of the image that you want to use in your namespace by replacing <new_image_repo\> and <new_tag\> respectively.

    Below is an example where <source_image\> is "hello-world", <tag\> is "latest", <region\> is "uk", <my_namespace\> is "namespace1", <new_image_repo\> is "hw_repo", and <new_tag\> is "1".

    ```bash
    docker tag hello-world:latest uk.icr.io/namespace1/hw_repo:1
    ```

    **5. Push images to your namespace**

    First, you'll need to log in to IBM Cloud Container Registry.

    ```bash title="Log in to ICR"
    ibmcloud cr login --client docker
    ```

    Once you've logged in, you can push the image up to your namespace in the registry.

    ```bash title="Push image to your namespace"
    docker push <region>.icr.io/<my_namespace>/<image_repo>:<tag>
    ```

    Replace <my_namespace\> with the namespace you created in step 2 and <image_repo\> and <tag\> with the repository and tag of the image you chose when you tagged the image in step 4.

    Below is an example where <region\> is "uk", <my_namespace\> is "namespace1", <image_repo\> is "hw_repo", and <tag\> is "1".

    ```bash
    docker push uk.icr.io/namespace1/hw_repo:1
    ```

    **6. Verify that the image was pushed**

    Verify that the image was pushed successfully by running the command below.

    ```bash
    ibmcloud cr image-list
    ```

    **7. Scan for vulnerabilities**

    IBM Cloud Registry includes Vulnerability Advisor to scan your images.

    ```bash title="Scan image for vulnerabilities"
    ibmcloud cr va <region>.icr.io/<my_namespace>/<image_repo>:<tag>
    ```

    You can also view your pushed images by clicking on the button below:

    [Images](https://cloud.ibm.com/containers/registry/images){ .md-button target="_blank"}

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

## Additional Resources

[Learn More about Quay :fontawesome-brands-redhat:](https://docs.redhat.com/en/documentation/red_hat_quay/3/){ .md-button target="_blank"}
[Learn More about ICR :fontawesome-solid-cloud:](https://cloud.ibm.com/docs/Registry?topic=Registry-getting-started&interface=ui){ .md-button target="_blank"}
[Docker Hub Documentation :fontawesome-brands-docker:](https://docs.docker.com/docker-hub/){ .md-button target="_blank"}
