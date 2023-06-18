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

=== "IBM Cloud"
    
    1. Install ibmcloud CLI
    ``` bash
    curl -fsSL https://clis.cloud.ibm.com/install/osx | sh
    ```

    2. Verify installation
    ``` bash
    ibmcloud help
    ```

    3. Configure environment. Go to cloud.ibm.com -> click on your profile -> Log into CLI and API and copy IBM Cloud CLI command. It will look something like this:
    ``` bash
    ibmcloud login -a https://cloud.ibm.com -u passcode -p <password>
    ```

    4. Log into docker through IBM Cloud
    ``` bash
    ibmcloud cr login --client docker
    ```
<!---
=== "Docker on Kubernetes/OpenShift"

    === "OpenShift"

        1. Login to your OpenShift cluster.
        ``` bash
        oc login...
        ```

        2. Apply the following yaml file to create the docker pod.
        ``` bash
        oc apply -f https://raw.githubusercontent.com/ibm-cloud-architecture/learning-cloudnative-101/master/static/yamls/containers/dind.yaml
        ```

        3. Then, we need to bash into the running pod.
        ``` bash
        oc exec -it dind
        ```

        4. Finally check to make sure you can run docker commands, such as
        ``` bash
        docker version
        ```
    
    === "Kubernetes"

        1. If you have already configured your Kubernetes, skip to step 5. First, add a user by setting credentials. Feel free to change the credential name, username and password to whatever you like.
        ``` bash
        kubectl config set-credentials kubeuser/foo.kubernetes.com --username=kubeuser --password=kubepassword
        ```

        2. Point to a cluster. Make sure the URI of the cluster matches the credential name you created in step 1.
        ``` bash
        kubectl config set-cluster foo.kubernetes.com --insecure-skip-tls-verify=true --server=https://foo.kubernetes.com
        ```

        3. Create a "context" that points to the cluster with a specific user.
        ``` bash
        kubectl config set-context default/foo.kubernetes.com/kubeuser --user=kubeuser/foo.kubernetes.com --namespace=default --cluster=foo.kubernetes.com
        ```

        4. Tell kubectl to use this context
        ``` bash
        kubectl config use-context default/foo.kubernetes.com/kubeuser
        ```

        5. Apply the following yaml file to create the docker pod.
        ``` bash
        kubectl apply -f https://raw.githubusercontent.com/ibm-cloud-architecture/learning-cloudnative-101/master/static/yamls/containers/dind.yaml
        ```

        6. Then, we need to bash into the running pod.
        ``` bash
        kubectl exec -it dind
        ```

        7. Finally check to make sure you can run docker commands, such as
        ``` bash
        docker version
        ```
--->
## Activities

| Task                    | Description                                                     | Link                                                                                                                         | Time   |
| ----------------------- | --------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------- | ------ |                                                       |                                                                                                                              |        |
| IBM Container Registry  | Build and Deploy Run using IBM Container Registry               | [IBM Container Registry](./activities/ibmcloud-cr)                                                                           | 30 min |
| Docker Lab              | Running a Sample Application on Docker                          | [Docker Lab](./labs/containers/index.md)                                                                                                  | 30 min |

Once you have completed these tasks, you should have a base understanding of containers and how to use Docker.
