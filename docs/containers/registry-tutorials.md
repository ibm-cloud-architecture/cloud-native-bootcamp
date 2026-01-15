# Registry Tutorials

This page provides step-by-step tutorials for working with popular container registries. Select a registry below to get started.

=== "IBM Cloud Registry"

    ## IBM Cloud Container Registry

    IBM Cloud Container Registry provides a multi-tenant, highly available, and scalable private image registry with integrated vulnerability scanning.

    ### Prerequisites

    - Docker or Podman installed and running
    - IBM Cloud account ([Sign up here](https://cloud.ibm.com/registration){target="_blank"})
    - IBM Cloud CLI installed

    ### Tutorial

    === "Podman"

        **1. Install the IBM Cloud CLI**

        ```bash
        curl -fsSL https://clis.cloud.ibm.com/install/osx | sh
        ```

        **2. Install the Container Registry plugin**

        ```bash
        ibmcloud plugin install container-registry
        ```

        **3. Login to IBM Cloud**

        ```bash
        ibmcloud login
        ```

        For federated accounts, use:

        ```bash
        ibmcloud login --sso
        ```

        **4. Set up a namespace**

        Create a namespace to organize your images:

        ```bash
        ibmcloud cr namespace-add my_namespace
        ```

        !!! note "Namespace Names"
            Namespace names must be unique across all IBM Cloud accounts in the same region. Choose a descriptive name like `mycompany-dev`.

        Verify the namespace was created:

        ```bash
        ibmcloud cr namespace-list
        ```

        **5. Login to the registry**

        ```bash
        ibmcloud cr login --client podman
        ```

        **6. Pull a base image**

        ```bash
        podman pull docker.io/library/hello-world:latest
        ```

        **7. Tag for IBM Cloud Registry**

        Tag the image with your region and namespace:

        ```bash
        podman tag hello-world:latest us.icr.io/my_namespace/hello-world:v1.0
        ```

        !!! info "Regional Endpoints"
            | Region | Endpoint |
            | ------ | -------- |
            | US South | `us.icr.io` |
            | EU Central | `de.icr.io` |
            | UK South | `uk.icr.io` |
            | AP North | `jp.icr.io` |
            | AP South | `au.icr.io` |

        **8. Push to IBM Cloud Registry**

        ```bash
        podman push us.icr.io/my_namespace/hello-world:v1.0
        ```

        **9. Verify your push**

        ```bash
        ibmcloud cr image-list
        ```

        **10. Scan for vulnerabilities**

        IBM Cloud Registry includes Vulnerability Advisor:

        ```bash
        ibmcloud cr va us.icr.io/my_namespace/hello-world:v1.0
        ```

        You can also view your images in the [IBM Cloud Console](https://cloud.ibm.com/containers/registry/images){target="_blank"}.

    === "Docker"

        **1. Install the IBM Cloud CLI**

        ```bash
        curl -fsSL https://clis.cloud.ibm.com/install/osx | sh
        ```

        **2. Install the Container Registry plugin**

        ```bash
        ibmcloud plugin install container-registry
        ```

        **3. Login to IBM Cloud**

        ```bash
        ibmcloud login
        ```

        For federated accounts, use:

        ```bash
        ibmcloud login --sso
        ```

        **4. Set up a namespace**

        Create a namespace to organize your images:

        ```bash
        ibmcloud cr namespace-add my_namespace
        ```

        !!! note "Namespace Names"
            Namespace names must be unique across all IBM Cloud accounts in the same region. Choose a descriptive name like `mycompany-dev`.

        Verify the namespace was created:

        ```bash
        ibmcloud cr namespace-list
        ```

        **5. Login to the registry**

        ```bash
        ibmcloud cr login --client docker
        ```

        **6. Pull a base image**

        ```bash
        docker pull hello-world:latest
        ```

        **7. Tag for IBM Cloud Registry**

        Tag the image with your region and namespace:

        ```bash
        docker tag hello-world:latest us.icr.io/my_namespace/hello-world:v1.0
        ```

        !!! info "Regional Endpoints"
            | Region | Endpoint |
            | ------ | -------- |
            | US South | `us.icr.io` |
            | EU Central | `de.icr.io` |
            | UK South | `uk.icr.io` |
            | AP North | `jp.icr.io` |
            | AP South | `au.icr.io` |

        **8. Push to IBM Cloud Registry**

        ```bash
        docker push us.icr.io/my_namespace/hello-world:v1.0
        ```

        **9. Verify your push**

        ```bash
        ibmcloud cr image-list
        ```

        **10. Scan for vulnerabilities**

        IBM Cloud Registry includes Vulnerability Advisor:

        ```bash
        ibmcloud cr va us.icr.io/my_namespace/hello-world:v1.0
        ```

        You can also view your images in the [IBM Cloud Console](https://cloud.ibm.com/containers/registry/images){target="_blank"}.

    ### IBM Cloud Registry Features

    | Feature | Description |
    | ------- | ----------- |
    | **Vulnerability Advisor** | Automatic security scanning with detailed reports |
    | **IAM Integration** | Fine-grained access control with IBM Cloud IAM |
    | **Multi-Region** | Deploy images across multiple regions |
    | **Retention Policies** | Automatic cleanup of old images |
    | **Private Network** | Access via IBM Cloud private network |

    ### Resources

    [IBM Cloud Registry Documentation :fontawesome-solid-cloud:](https://cloud.ibm.com/docs/Registry?topic=Registry-getting-started){ .md-button target="_blank"}

=== "Red Hat Quay"

    ## Red Hat Quay

    Red Hat Quay is an enterprise container registry that provides security scanning, geo-replication, and detailed access controls. It's commonly used in OpenShift environments.

    ### Prerequisites

    - Docker or Podman installed and running
    - A free Quay.io account ([Sign up here](https://quay.io/signin/){target="_blank"})

    ### Tutorial

    === "Podman"

        **1. Login to Quay.io**

        ```bash
        podman login quay.io
        ```

        Enter your Quay.io username and password when prompted:

        ```text
        Username: your_username
        Password: your_password
        Login Succeeded!
        ```

        **2. Pull a base image**

        Pull an image from Docker Hub to use as a starting point:

        ```bash
        podman pull docker.io/library/alpine:latest
        ```

        **3. Create a simple container**

        Run a container and make a small modification:

        ```bash
        podman run -it --name my-alpine docker.io/library/alpine:latest /bin/sh
        ```

        Inside the container, create a file:

        ```bash
        echo "Hello from Quay!" > /hello.txt
        exit
        ```

        **4. Commit the container to a new image**

        ```bash
        podman commit my-alpine my-quay-image:v1.0
        ```

        **5. Tag for Quay.io**

        Tag the image with your Quay.io username and repository name:

        ```bash
        podman tag my-quay-image:v1.0 quay.io/your_username/my-quay-image:v1.0
        ```

        !!! note "Replace `your_username`"
            Replace `your_username` with your actual Quay.io username.

        **6. Push to Quay.io**

        ```bash
        podman push quay.io/your_username/my-quay-image:v1.0
        ```

        **7. Verify your push**

        Visit [Quay.io Repositories](https://quay.io/repository/){target="_blank"} to see your pushed image.

        !!! tip "Repository Visibility"
            By default, new repositories on Quay.io are private. You can change visibility in the repository settings.

        **8. Clean up**

        ```bash
        podman rm my-alpine
        podman rmi my-quay-image:v1.0
        ```

    === "Docker"

        **1. Login to Quay.io**

        ```bash
        docker login quay.io
        ```

        Enter your Quay.io username and password when prompted:

        ```text
        Username: your_username
        Password: your_password
        Login Succeeded!
        ```

        **2. Pull a base image**

        Pull an image from Docker Hub to use as a starting point:

        ```bash
        docker pull alpine:latest
        ```

        **3. Create a simple container**

        Run a container and make a small modification:

        ```bash
        docker run -it --name my-alpine alpine:latest /bin/sh
        ```

        Inside the container, create a file:

        ```bash
        echo "Hello from Quay!" > /hello.txt
        exit
        ```

        **4. Commit the container to a new image**

        ```bash
        docker commit my-alpine my-quay-image:v1.0
        ```

        **5. Tag for Quay.io**

        Tag the image with your Quay.io username and repository name:

        ```bash
        docker tag my-quay-image:v1.0 quay.io/your_username/my-quay-image:v1.0
        ```

        !!! note "Replace `your_username`"
            Replace `your_username` with your actual Quay.io username.

        **6. Push to Quay.io**

        ```bash
        docker push quay.io/your_username/my-quay-image:v1.0
        ```

        **7. Verify your push**

        Visit [Quay.io Repositories](https://quay.io/repository/){target="_blank"} to see your pushed image.

        !!! tip "Repository Visibility"
            By default, new repositories on Quay.io are private. You can change visibility in the repository settings.

        **8. Clean up**

        ```bash
        docker rm my-alpine
        docker rmi my-quay-image:v1.0
        ```

    ### Quay.io Features

    Once your image is pushed, Quay.io automatically provides:

    | Feature | Description |
    | ------- | ----------- |
    | **Security Scanning** | Automatic vulnerability scanning of your images |
    | **Build Triggers** | Automatically build images from Git repositories |
    | **Robot Accounts** | Service accounts for CI/CD automation |
    | **Teams & Permissions** | Fine-grained access control |
    | **Image Expiration** | Automatic cleanup of old tags |

    ### Resources

    [Quay.io Documentation :fontawesome-brands-redhat:](https://docs.redhat.com/en/documentation/red_hat_quay/3/){ .md-button target="_blank"}

=== "Docker Hub"

    ## Docker Hub

    Docker Hub is the default registry for Docker and contains millions of public images. It's the easiest way to get started with container registries.

    ### Prerequisites

    - Docker or Podman installed and running
    - A free Docker Hub account ([Sign up here](https://hub.docker.com/signup){target="_blank"})

    ### Tutorial

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

        Enter your Docker Hub username and password when prompted.

        **4. Tag your image**

        ```bash
        podman tag myapp:latest docker.io/yourusername/myapp:v1.0
        ```

        **5. Push to Docker Hub**

        ```bash
        podman push docker.io/yourusername/myapp:v1.0
        ```

        **6. Verify your push**

        Visit [Docker Hub](https://hub.docker.com/){target="_blank"} and navigate to your repositories to see your pushed image.

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

        Enter your Docker Hub username and password when prompted.

        **4. Tag your image**

        ```bash
        docker tag myapp:latest yourusername/myapp:v1.0
        ```

        **5. Push to Docker Hub**

        ```bash
        docker push yourusername/myapp:v1.0
        ```

        **6. Verify your push**

        Visit [Docker Hub](https://hub.docker.com/){target="_blank"} and navigate to your repositories to see your pushed image.

    ### Resources

    [Docker Hub Documentation :fontawesome-brands-docker:](https://docs.docker.com/docker-hub/){ .md-button target="_blank"}
