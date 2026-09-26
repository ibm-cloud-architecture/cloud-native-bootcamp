---
tags:
  - Lab
  - Containers
  - Beginner
---

# Containers Lab

<span class="lab-badge">45 min</span> <span class="lab-badge">Beginner</span>

In this lab you'll build a container image for a small web service, run it, inspect it, and push it to a public registry.

The lab doesn't hand you every command. **Each step describes what to do. Work out the command yourself**, then expand the solution to check your answer.

## Prerequisites

- A container engine:
    - **[Podman](https://podman.io/docs/installation)** (recommended). It's daemonless and runs rootless by default, and it's what OpenShift uses under the hood. On macOS and Windows, run `podman machine init` and `podman machine start` once after installing.
    - **[Docker](https://docs.docker.com/get-started/get-docker/)** also works. Every `podman` command in this lab works the same with `docker`.
- A free **[Quay.io](https://quay.io/)** account, used to push your image in Part 4.

## Part 1: Verify your setup

1. Print the version of your container engine.

    ??? success "Solution"
        ```bash
        podman version
        ```

2. Run the `quay.io/podman/hello` container. Because the image isn't on your machine yet, it's pulled from the registry first.

    ??? success "Solution"
        ```bash
        podman run --rm quay.io/podman/hello
        ```

        `--rm` deletes the container as soon as it exits.

    ```text title="Expected output (abridged)"
    Trying to pull quay.io/podman/hello:latest...
    ...
    !... Hello Podman World ...!
    ```

3. List the images stored on your machine.

    ??? success "Solution"
        ```bash
        podman images
        ```

## Part 2: Build an image

### Create the application

Create a new directory named `greeting` for the application:

```bash
mkdir greeting && cd greeting
```

Save the following as `main.go`. It's a small HTTP service that returns a JSON greeting and reads its message from an environment variable:

```go title="main.go"
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

func main() {
	message := os.Getenv("GREETING")
	if message == "" {
		message = "Welcome to the Cloud Native Bootcamp!"
	}

	http.HandleFunc("/greeting", func(w http.ResponseWriter, r *http.Request) {
		name := r.URL.Query().Get("name")
		if name == "" {
			name = "World"
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{
			"message": message,
			"name":    name,
		})
	})
	http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("ok"))
	})

	log.Println("greeting service listening on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
```

Save this as `go.mod`:

```text title="go.mod"
module greeting

go 1.22
```

You don't need Go installed. The build happens inside a container.

### Write the Containerfile

A `Containerfile` (Docker calls it a `Dockerfile`, and both tools accept either name) describes how to build the image. Save this as `Containerfile`:

```dockerfile title="Containerfile"
# Stage 1: compile the Go binary with Red Hat's Go toolchain image
FROM registry.access.redhat.com/ubi9/go-toolset AS builder
COPY --chown=1001:0 . .
RUN CGO_ENABLED=0 go build -o greeting .

# Stage 2: copy only the binary into a minimal runtime image
FROM registry.access.redhat.com/ubi9/ubi-micro
COPY --from=builder /opt/app-root/src/greeting /usr/local/bin/greeting
EXPOSE 8080
USER 1001
CMD ["greeting"]
```

- `FROM` sets the base image. It starts each **stage** of the build.
- `COPY` copies files into the image. `--from=builder` copies from an earlier stage instead of from your directory.
- `RUN` runs a command at build time.
- `EXPOSE` documents the port the app listens on.
- `USER` runs the app as a non-root user. OpenShift ignores this and assigns a random UID, which is why the app doesn't depend on a particular user.
- `CMD` is the command that runs when the container starts.

This is a **multi-stage build**. The first stage contains the whole Go toolchain, which is several hundred MB. The final image contains only the compiled binary on top of `ubi-micro`, so it's around 30 MB. Smaller images pull faster, start faster, and have fewer packages that could contain vulnerabilities.

### Build it

4. Build the image from the current directory and tag it `greeting:v1.0.0`.

    ??? success "Solution"
        ```bash
        podman build -t greeting:v1.0.0 .
        ```

    ```text title="Expected output (abridged)"
    [1/2] STEP 1/3: FROM registry.access.redhat.com/ubi9/go-toolset AS builder
    ...
    [2/2] STEP 5/5: CMD ["greeting"]
    [2/2] COMMIT greeting:v1.0.0
    Successfully tagged localhost/greeting:v1.0.0
    ```

5. List your images again and compare the size of `greeting` with `go-toolset`.

    ??? success "Solution"
        ```bash
        podman images
        ```

    ```text title="Expected output (abridged)"
    REPOSITORY                                     TAG     IMAGE ID      CREATED        SIZE
    localhost/greeting                             v1.0.0  9a182f49a53c  1 minute ago   32.8 MB
    registry.access.redhat.com/ubi9/go-toolset     latest  f2ea3c4b2b32  2 days ago     1.16 GB
    registry.access.redhat.com/ubi9/ubi-micro      latest  23bcc0c14418  10 days ago    24.7 MB
    ```

## Part 3: Run and inspect the container

6. Run the image in the background (detached), name the container `greeting`, and map port `8080` on your machine to port `8080` in the container.

    ??? success "Solution"
        ```bash
        podman run -d --name greeting -p 8080:8080 greeting:v1.0.0
        ```

    !!! tip "Port already in use?"
        If something else on your machine uses port 8080, map a different host port, for example `-p 9080:8080`, and use that port in the steps below.

7. Call the service:

    ```bash
    curl "localhost:8080/greeting?name=John"
    ```

    ```json
    {"message":"Welcome to the Cloud Native Bootcamp!","name":"John"}
    ```

8. Try to run a second container with the same name. What happens?

    ??? success "Solution"
        ```bash
        podman run -d --name greeting -p 8081:8080 greeting:v1.0.0
        ```

        ```text
        Error: creating container storage: the container name "greeting" is already in use by 3c1f.... You have to remove that container to be able to reuse that name: that name is already in use
        ```

        Container names must be unique. Naming containers makes them easy to find and manage.

9. List the running containers.

    ??? success "Solution"
        ```bash
        podman ps
        ```

10. Inspect the container to see its full configuration: environment variables, network settings, mounts and state. Then use a Go template to print only its IP address and state.

    ??? success "Solution"
        ```bash
        podman inspect greeting
        podman inspect greeting --format '{{.State.Status}} {{.NetworkSettings.IPAddress}}'
        ```

11. Show the container's logs.

    ??? success "Solution"
        ```bash
        podman logs greeting
        ```

        ```text
        2026/09/24 23:29:00 greeting service listening on :8080
        ```

        Add `-f` to follow the logs as new lines are written.

12. Run a command **inside** the running container to see which user the app runs as.

    ??? success "Solution"
        ```bash
        podman exec greeting id
        ```

        ```text
        uid=1001(1001) gid=0(root) groups=0(root)
        ```

13. Stop and remove the container, then start a new one with the `GREETING` environment variable set to a message of your choice, and call it again.

    ??? success "Solution"
        ```bash
        podman stop greeting
        podman rm greeting
        podman run -d --name greeting -p 8080:8080 -e GREETING="Hello from my container" greeting:v1.0.0
        curl "localhost:8080/greeting?name=John"
        ```

        This is how containers are configured: the same image, with different settings supplied at runtime. Kubernetes does the same with ConfigMaps and Secrets.

## Part 4: Push the image to a registry

A **container registry** stores and distributes images. Docker Hub, Quay.io and GitHub Container Registry are public registries. OpenShift also has a built-in internal registry.

14. Log in to Quay.io.

    ??? success "Solution"
        ```bash
        podman login quay.io
        ```

        If your Quay account uses single sign-on (for example, a Red Hat login), create an **encrypted password** under **Account Settings > Docker CLI Password** and use it here instead of your account password.

15. Tag your image for your Quay repository: `quay.io/<your-username>/greeting:v1.0.0`. The tag includes the registry hostname, which tells the engine where to push.

    ??? success "Solution"
        ```bash
        export QUAY_USER=<your-username>
        podman tag greeting:v1.0.0 quay.io/${QUAY_USER}/greeting:v1.0.0
        ```

16. Push the image.

    ??? success "Solution"
        ```bash
        podman push quay.io/${QUAY_USER}/greeting:v1.0.0
        ```

17. On [quay.io](https://quay.io/), open the new `greeting` repository and, under **Settings**, make it **public**. New repositories are private by default.

18. Remove the local images, then pull your image back from Quay.

    ??? success "Solution"
        ```bash
        podman rm -f greeting
        podman rmi quay.io/${QUAY_USER}/greeting:v1.0.0 greeting:v1.0.0
        podman pull quay.io/${QUAY_USER}/greeting:v1.0.0
        ```

!!! warning "Building on Apple Silicon (M-series Macs)?"
    Images you build on an ARM Mac are `arm64` by default, but most OpenShift clusters run on `amd64` (x86_64) nodes. Pods fail there with `exec format error`. Build for the target platform, or build a multi-arch image that covers both:

    ```bash
    # Single platform
    podman build --platform linux/amd64 -t quay.io/${QUAY_USER}/greeting:v1.0.0 .

    # Multi-arch manifest list for amd64 and arm64
    podman build --platform linux/amd64,linux/arm64 --manifest quay.io/${QUAY_USER}/greeting:v1.0.0 .
    podman manifest push quay.io/${QUAY_USER}/greeting:v1.0.0
    ```

## Cleanup

```bash
podman rm -f greeting
podman rmi greeting:v1.0.0
```

Keep the `greeting` image on Quay. The [Image Registry Lab](container-registry/index.md) deploys it to OpenShift.

## What you learned

- [x] Building images with a Containerfile and multi-stage builds
- [x] Running, inspecting and configuring containers
- [x] Tagging and pushing images to a registry
- [x] Building images for the right CPU architecture
