# Image Registries

A registry is a repository used to store and access container images. Container registries can support container-based application development, often as part of DevOps processes.

Container registries save developers valuable time in the creation and delivery of cloud-native applications, acting as the intermediary for sharing container images between systems. They essentially act as a place for developers to store container images and share them out via a process of uploading (pushing) to the registry and downloading (pulling) into another system, like a Kubernetes cluster.

[Learn More :fontawesome-solid-globe:](https://www.redhat.com/en/topics/cloud-native-apps/what-is-a-container-registry){ .md-button target="_blank"}

=== "Tutorial"

      Make sure you have Docker Desktop installed and up and running.

      ``` Bash title="Login to Quay"
      docker login quay.io
      Username: your_username
      Password: your_password
      Email: your_email
      ```

      First we'll create a container with a single new file based off of the busybox base image: 
      ``` Bash title="Create a new container"
      docker run busybox echo "fun" > newfile
      ```
      The container will immediately terminate, so we'll use the command below to list it:
      ```
      docker ps -l
      ```
      The next step is to commit the container to an image and then tag that image with a relevant name so it can be saved to a respository.

      Replace "container_id" with your container id from the previous command.
      ``` Bash title="Create a new image"
      docker commit container_id quay.io/your_username/repository_name
      ```
      Be sure to replace "your_username" with your quay.io username and "respository_name" with a unique name for your repository.

      Now that we've tagged our image with a repository name, we can push the respository to Quay Container Registry:
      ``` Bash title="Push the image to Quay"
      docker push quay.io/your_username/repository_name
      ```
      Your respository has now been pushed to Quay Container Registry!

      To view your repository, click on the button below:
      
      [Repositories](https://quay.io/repository/){ .md-button target="_blank"}

      