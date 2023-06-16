# Containers

Containers are a standard way to package an application and all its dependencies so that it can be moved between environments and run without change. They work by hiding the differences between applications inside the container so that everything outside the container can be standardized.

For example, Docker created standard way to create images for Linux Containers.

## Resources

[Container Basics :fontawesome-regular-file-pdf:](../containers/materials/02-Containers-Basics.pdf){ .md-button }

## Basic Docker Commands

| Action                      | Command                                     |
| --------------------------- | ------------------------------------------- |
| Get Docker version          | `docker version`                            |
| Run `hello-world` Container | `docker run hello-world`                    |
| List Running Containers     | `docker ps`                                 |
| Stop a container            | `docker stop <container-name/container-id>` |
| List Docker Images          | `docker images`                            |
| Login into registry         | `docker login`                              |
| Build an image              | `docker build -t <image_name>:<tag> .`      |
| Inspect a docker object     | `docker inspect <name/id>`                 |
| Inspect a docker image      | `docker inspect image <name/id>`           |
| Pull an image               | `docker pull <image_name>:<tag>`           |
| Push an Image               | `docker push <image_name>:<tag>`           |
| Remove a container          | `docker rm <container-name/container-id>`  |

## Running Docker

=== "Local Docker"

    1. Install Docker Desktop

    2. Test it out

=== "Docker on Kubernetes/OpenShift"

    1. Login to your Kubernetes or OpenShift cluster.
    ``` bash
    oc login...
    ```

    2. Apply the following yaml file to create the docker pod.
    ``` bash
    kubectl apply -f https://raw.githubusercontent.com/ibm-cloud-architecture/learning-cloudnative-101/master/static/yamls/containers/dind.yaml
    ```

    3. Then, we need to bash into the running pod.
    ``` bash
    kubectl exec -it dind
    ```

    4. Finally check to make sure you can run docker commands, such as
    ``` bash
    docker version
    ```

## Activities

| Task                    | Description                                                     | Link                                                                                                                         | Time   |
| ----------------------- | --------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------- | ------ |
| **_ Walkthroughs _**    |                                                                 |                                                                                                                              |        |
| What is a Container?    | A look under the the covers at what is a Linux Container?       | <a href="https://www.katacoda.com/courses/container-runtimes/what-is-a-container" target="_blank">Understand Containers</a>  | 10 min |
| What is an Image?       | A look under the the covers at what is a Linux Container Image? | <a href="https://www.katacoda.com/courses/container-runtimes/what-is-a-container-image" target="_blank">Container Images</a> | 10 min |
| Docker Basics           | Set of walkthroughs that cover docker basics                    | <a href="https://www.katacoda.com/courses/docker" target="_blank">Docker Basics</a>                                          | 10 min |
| **_ Try It Yourself _** |                                                                 |                                                                                                                              |        |
| IBM Container Registry  | Build and Deploy Run using IBM Container Registry               | [IBM Container Registry](./activities/ibmcloud-cr)                                                                           | 30 min |
| Docker Lab              | Running a Sample Application on Docker                          | [Docker Lab](./activities/)                                                                                                  | 30 min |

Once you have completed these tasks, you should have a base understanding of containers and how to use Docker.
