# Container References

## Basic CLI Commands

=== "Podman"

    | Action                    | Command                                                    |
    | ------------------------- | ---------------------------------------------------------- |
    | Check Podman version      | `podman --version`                                         |
    | Check host information    | `podman info`                                              |
    | List images               | `podman images`                                            |
    | Pull image                | `podman pull <image-name>:<tag>`                           |
    | Run image                 | `podman run <image-name>:<tag>`                            |
    | List running containers   | `podman ps`                                                |
    | List all containers       | `podman ps -a`                                             |
    | Inspect a container       | `podman inspect <container-id>`                            |
    | View container logs       | `podman logs <container-id>`                               |
    | Stop a running container  | `podman stop <container-id>`                               |
    | Kill a running container  | `podman kill <container-id>`                               |
    | Build Podman image        | `podman build -t <image_name>:<tag> -f Containerfile .`    |
    | Push image                | `podman push <image_name>:<tag>`                           |
    | Remove stopped containers | `podman rm <container-id>`                                 |
    | Remove image              | `podman rmi -f <image-name>` or `podman rmi -f <image-id>` |

=== "Docker"

    | Action                      | Command                                     |
    | --------------------------- | ------------------------------------------- |
    | Get Docker version          | `docker version`                            |
    | Run `hello-world` Container | `docker run hello-world`                    |
    | List Running Containers     | `docker ps`                                 |
    | List all containers         | `docker ps -a`                              |
    | Stop a container            | `docker stop <container-name/container-id>` |
    | List Docker Images          | `docker images`                             |
    | Login into registry         | `docker login`                              |
    | Build an image              | `docker build -t <image_name>:<tag> .`      |
    | Inspect a docker object     | `docker inspect <name/id>`                  |
    | Inspect a docker image      | `docker inspect image <name/id>`            |
    | View container logs         | `docker logs <container-id>`                |
    | Pull an image               | `docker pull <image_name>:<tag>`            |
    | Push an Image               | `docker push <image_name>:<tag>`            |
    | Remove a container          | `docker rm <container-name/container-id>`   |

## Running Containers

Common options for running containers:

=== "Podman"

    ```bash
    # Run in background (detached mode)
    podman run -d <image>

    # Run with interactive terminal
    podman run -it <image> /bin/sh

    # Run with port mapping (host:container)
    podman run -p 8080:80 <image>

    # Run with environment variables
    podman run -e MY_VAR=value <image>

    # Run with volume mount
    podman run -v /host/path:/container/path <image>

    # Run with container name
    podman run --name mycontainer <image>

    # Run with resource limits
    podman run --memory 512m --cpus 0.5 <image>

    # Run with automatic removal on exit
    podman run --rm <image>

    # Run as specific user
    podman run --user 1001:1001 <image>
    ```

=== "Docker"

    ```bash
    # Run in background (detached mode)
    docker run -d <image>

    # Run with interactive terminal
    docker run -it <image> /bin/sh

    # Run with port mapping (host:container)
    docker run -p 8080:80 <image>

    # Run with environment variables
    docker run -e MY_VAR=value <image>

    # Run with volume mount
    docker run -v /host/path:/container/path <image>

    # Run with container name
    docker run --name mycontainer <image>

    # Run with resource limits
    docker run --memory 512m --cpus 0.5 <image>

    # Run with automatic removal on exit
    docker run --rm <image>

    # Run as specific user
    docker run --user 1001:1001 <image>
    ```

## Networking Commands

=== "Podman"

    | Action                  | Command                                              |
    | ----------------------- | ---------------------------------------------------- |
    | List networks           | `podman network ls`                                  |
    | Create network          | `podman network create <network-name>`               |
    | Inspect network         | `podman network inspect <network-name>`              |
    | Connect container       | `podman network connect <network> <container>`       |
    | Disconnect container    | `podman network disconnect <network> <container>`    |
    | Remove network          | `podman network rm <network-name>`                   |
    | Run with network        | `podman run --network <network-name> <image>`        |

=== "Docker"

    | Action                  | Command                                              |
    | ----------------------- | ---------------------------------------------------- |
    | List networks           | `docker network ls`                                  |
    | Create network          | `docker network create <network-name>`               |
    | Create bridge network   | `docker network create --driver bridge <name>`       |
    | Inspect network         | `docker network inspect <network-name>`              |
    | Connect container       | `docker network connect <network> <container>`       |
    | Disconnect container    | `docker network disconnect <network> <container>`    |
    | Remove network          | `docker network rm <network-name>`                   |
    | Run with network        | `docker run --network <network-name> <image>`        |

### Network Types

| Type | Description |
| ---- | ----------- |
| **bridge** | Default network driver. Containers on the same bridge can communicate. |
| **host** | Remove network isolation, container uses host's network directly. |
| **none** | Disable all networking for the container. |
| **overlay** | Connect containers across multiple Docker hosts (Swarm mode). |

## Volume Commands

=== "Podman"

    | Action              | Command                                           |
    | ------------------- | ------------------------------------------------- |
    | List volumes        | `podman volume ls`                                |
    | Create volume       | `podman volume create <volume-name>`              |
    | Inspect volume      | `podman volume inspect <volume-name>`             |
    | Remove volume       | `podman volume rm <volume-name>`                  |
    | Remove unused       | `podman volume prune`                             |
    | Run with volume     | `podman run -v <volume>:/path <image>`            |
    | Run with bind mount | `podman run -v /host/path:/container/path <image>`|

=== "Docker"

    | Action              | Command                                            |
    | ------------------- | -------------------------------------------------- |
    | List volumes        | `docker volume ls`                                 |
    | Create volume       | `docker volume create <volume-name>`               |
    | Inspect volume      | `docker volume inspect <volume-name>`              |
    | Remove volume       | `docker volume rm <volume-name>`                   |
    | Remove unused       | `docker volume prune`                              |
    | Run with volume     | `docker run -v <volume>:/path <image>`             |
    | Run with bind mount | `docker run -v /host/path:/container/path <image>` |

### Volume Types

| Type | Syntax | Use Case |
| ---- | ------ | -------- |
| **Named volume** | `-v myvolume:/app/data` | Persistent data managed by Docker/Podman |
| **Bind mount** | `-v /host/path:/container/path` | Share files between host and container |
| **tmpfs mount** | `--tmpfs /app/temp` | Temporary data in memory (not persisted) |

## Resource Limits

Control container resource usage:

=== "Podman"

    ```bash
    # Limit memory
    podman run --memory 512m <image>

    # Limit memory with swap
    podman run --memory 512m --memory-swap 1g <image>

    # Limit CPU cores
    podman run --cpus 0.5 <image>

    # Limit CPU shares (relative weight)
    podman run --cpu-shares 512 <image>

    # Limit specific CPUs
    podman run --cpuset-cpus 0,1 <image>

    # Limit block I/O
    podman run --blkio-weight 500 <image>
    ```

=== "Docker"

    ```bash
    # Limit memory
    docker run --memory 512m <image>

    # Limit memory with swap
    docker run --memory 512m --memory-swap 1g <image>

    # Limit CPU cores
    docker run --cpus 0.5 <image>

    # Limit CPU shares (relative weight)
    docker run --cpu-shares 512 <image>

    # Limit specific CPUs
    docker run --cpuset-cpus 0,1 <image>

    # Limit block I/O
    docker run --blkio-weight 500 <image>
    ```

## Health Checks

Monitor container health:

=== "Podman"

    ```bash
    # Run with health check
    podman run \
      --health-cmd "curl -f http://localhost/ || exit 1" \
      --health-interval 30s \
      --health-timeout 10s \
      --health-retries 3 \
      --health-start-period 40s \
      <image>

    # Check container health status
    podman inspect --format='{{.State.Health.Status}}' <container>

    # View health check logs
    podman inspect --format='{{json .State.Health}}' <container> | jq
    ```

=== "Docker"

    ```bash
    # Run with health check
    docker run \
      --health-cmd "curl -f http://localhost/ || exit 1" \
      --health-interval 30s \
      --health-timeout 10s \
      --health-retries 3 \
      --health-start-period 40s \
      <image>

    # Check container health status
    docker inspect --format='{{.State.Health.Status}}' <container>

    # View health check logs
    docker inspect --format='{{json .State.Health}}' <container> | jq
    ```

## Docker Compose / Podman Compose

Manage multi-container applications:

=== "Podman"

    | Action                  | Command                                  |
    | ----------------------- | ---------------------------------------- |
    | Start services          | `podman-compose up`                      |
    | Start in background     | `podman-compose up -d`                   |
    | Stop services           | `podman-compose down`                    |
    | View logs               | `podman-compose logs`                    |
    | List running services   | `podman-compose ps`                      |
    | Build images            | `podman-compose build`                   |
    | Pull images             | `podman-compose pull`                    |
    | Restart services        | `podman-compose restart`                 |
    | Execute in service      | `podman-compose exec <service> <cmd>`    |

    !!! note "Podman Compose Installation"
        ```bash
        pip install podman-compose
        ```

=== "Docker"

    | Action                  | Command                                  |
    | ----------------------- | ---------------------------------------- |
    | Start services          | `docker compose up`                      |
    | Start in background     | `docker compose up -d`                   |
    | Stop services           | `docker compose down`                    |
    | Stop and remove volumes | `docker compose down -v`                 |
    | View logs               | `docker compose logs`                    |
    | Follow logs             | `docker compose logs -f`                 |
    | List running services   | `docker compose ps`                      |
    | Build images            | `docker compose build`                   |
    | Pull images             | `docker compose pull`                    |
    | Restart services        | `docker compose restart`                 |
    | Execute in service      | `docker compose exec <service> <cmd>`    |

### Example docker-compose.yml

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8080:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgres://db:5432/myapp
    depends_on:
      - db
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:16-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password

volumes:
  postgres_data:
```

## Cleanup Commands

=== "Podman"

    | Action                     | Command                        |
    | -------------------------- | ------------------------------ |
    | Remove stopped containers  | `podman container prune`       |
    | Remove unused images       | `podman image prune`           |
    | Remove all unused images   | `podman image prune -a`        |
    | Remove unused volumes      | `podman volume prune`          |
    | Remove unused networks     | `podman network prune`         |
    | Remove all unused data     | `podman system prune`          |
    | Remove everything          | `podman system prune -a --volumes` |

=== "Docker"

    | Action                     | Command                        |
    | -------------------------- | ------------------------------ |
    | Remove stopped containers  | `docker container prune`       |
    | Remove unused images       | `docker image prune`           |
    | Remove all unused images   | `docker image prune -a`        |
    | Remove unused volumes      | `docker volume prune`          |
    | Remove unused networks     | `docker network prune`         |
    | Remove all unused data     | `docker system prune`          |
    | Remove everything          | `docker system prune -a --volumes` |

## Running the CLI

=== "Local Podman"

    1. a. RECOMMENDED: Download Podman Desktop [here](https://podman-desktop.io/){target="_blank"}

        b. Alternative: Brew Installation
        ```bash
        brew install podman
        ```

    2. Create and start your first Podman machine
    ```bash
    podman machine init
    podman machine start
    ```

    3. Verify Podman installation
    ```bash
    podman info
    ```

    4. Test it out: [Podman Introduction](https://docs.podman.io/en/latest/Introduction.html){target="_blank"}

=== "Local Docker"

    1. Install Docker Desktop [here](https://docs.docker.com/desktop/){target="_blank"}

    2. Verify installation
    ```bash
    docker version
    ```

    3. Test it out: [Getting Started with Docker](https://docs.docker.com/get-started/introduction/){target="_blank"}

=== "IBM Cloud"

    1. Install ibmcloud CLI
    ```bash
    curl -fsSL https://clis.cloud.ibm.com/install/osx | sh
    ```

    2. Verify installation
    ```bash
    ibmcloud help
    ```

    3. Configure environment. Go to cloud.ibm.com -> click on your profile -> Log into CLI and API and copy IBM Cloud CLI command. It will look something like this:
    ```bash
    ibmcloud login -a https://cloud.ibm.com -u passcode -p <password>
    ```

    4. Log into container registry through IBM Cloud
    ```bash
    ibmcloud cr login --client docker
    # or
    ibmcloud cr login --client podman
    ```

## Security Commands

=== "Podman"

    ```bash
    # Run rootless (default in Podman)
    podman run <image>

    # Run with read-only filesystem
    podman run --read-only <image>

    # Drop all capabilities
    podman run --cap-drop ALL <image>

    # Add specific capability
    podman run --cap-add NET_BIND_SERVICE <image>

    # Run with no new privileges
    podman run --security-opt no-new-privileges <image>

    # Run with SELinux label
    podman run --security-opt label=level:s0:c100,c200 <image>
    ```

=== "Docker"

    ```bash
    # Run with read-only filesystem
    docker run --read-only <image>

    # Drop all capabilities
    docker run --cap-drop ALL <image>

    # Add specific capability
    docker run --cap-add NET_BIND_SERVICE <image>

    # Run with no new privileges
    docker run --security-opt no-new-privileges <image>

    # Run as non-root user
    docker run --user 1001:1001 <image>

    # Run with seccomp profile
    docker run --security-opt seccomp=profile.json <image>
    ```

## Activities

| Task                   | Description                                       | Link                                                                     | Time   |
| ---------------------- | ------------------------------------------------- | ------------------------------------------------------------------------ | ------ |
| IBM Container Registry | Build and Deploy Run using IBM Container Registry | [IBM Container Registry](../labs/containers/container-registry/index.md) | 30 min |
| Docker Lab             | Running a Sample Application on Docker            | [Docker Lab](../labs/containers/index.md)                                | 30 min |

Once you have completed these tasks, you should have a base understanding of containers and how to use Docker and Podman.

## Additional Resources

- [Docker CLI Reference](https://docs.docker.com/engine/reference/commandline/cli/)
- [Podman CLI Reference](https://docs.podman.io/en/latest/Commands.html)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Container Security Best Practices](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
