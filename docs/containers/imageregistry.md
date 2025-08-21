# What are Image Registries

A registry is a repository used to store and access container images. Container registries can support container-based application development, often as part of DevOps processes.

Container registries save developers valuable time in the creation and delivery of cloud-native applications, acting as the intermediary for sharing container images between systems. They essentially act as a place for developers to store container images and share them out via a process of uploading (pushing) to the registry and downloading (pulling) into another system, like a Kubernetes cluster.

Some examples of an image registry are **Red Hat Quay** and **IBM Cloud Registry**.

[Learn More :fontawesome-solid-globe:](https://www.redhat.com/en/topics/cloud-native-apps/what-is-a-container-registry){ .md-button target="\_blank"}

## Quay Tutorial

=== "Podman"

      Make sure you have Podman Desktop installed and up and running.

      Here's how to find a list of publicly available container images on DockerHub.

      ``` Bash title="Find Container Image"
      podman search docker.io/busybox
      ```

      ``` Bash title="Output:"
      NAME                                         DESCRIPTION
      docker.io/library/busybox                    Busybox base image.
      docker.io/rancher/busybox
      docker.io/openebs/busybox-client
      docker.io/antrea/busybox
      docker.io/hugegraph/busybox                  test image
      ...
      ```

      We can create a _busybox_ container image based off of the _busybox_ base image you see listed in the output above.

      ``` Bash title="Create Image"
      podman run -it docker.io/library/busybox
      ```

      The _-it_ flag allows you to run the image in interactive mode. Interactive mode in Podman allows you to run a shell in a container and interact with it. However, you'll see that running small containers like this one don't have much to play around with in the interactive mode. To exit out of the interactive mode:

      ``` Bash title="Exit Interactive mode"
      exit
      ```

      You can also share images in a public registry so that others can use and review them. Here's how to push your image up to quay.io.

      ``` Bash title="Login to quay.io"
      podman login quay.io
      ```
      Enter in the following info:

      ```
      Username: your_username
      Password: your_password
      ```

      Next, tag the image so that you can push it and find it in your account.

      ``` Bash title="Tag Image"
      podman tag <image_name> quay.io/your_username/image_registry_name
      ```

      Make sure to replace "image_name" with the name of the image you want to push up to quay.
      Replace "user_name" with your quay.io username.
      Replace "image_registry_name" with what you want the image to be named/labeled as in quay.

      Once the image is tagged, you can push it up to quay.

      ``` Bash title="Push Image"
      podman push quay.io/your_username/image_registry_name
      ```

      Your respository has now been pushed to Quay Container Registry!

      To view your repository, click on the button below:

      [Repositories](https://quay.io/repository/){ .md-button target="_blank"}

=== "Docker"

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

## IBM Cloud Registry Tutorial

=== "Podman"

      **1. Install the Container Registry CLI**

      Before you begin, you need to install the IBM Cloud CLI so that you can run the IBM Cloud ***ibmcloud*** commands.
      ``` Bash title="Install the container-registry CLI"
      ibmcloud plugin install container-registry
      ```
      **2. Set up a namespace**

      Then, you need to create a namespace. The namespace is created in the resource group that you specify so that you can configure access to resources within the namespace at the resource group level. If you don't specify a resource group, then the default is used.
      ``` Bash title="Log in to IBM Cloud"
      ibmcloud login
      ```

      ``` Bash title="Create namespace"
      ibmcloud cr namespace-add <my_namespace>
      ```
      Make sure to replace <my_namespace\> with your preferred namespace.

      If you want to create the namespace in a specific resource group, use the following code **before** creating the namespace.
      ``` Bash title="Specify a resource group"
      ibmcloud target -g <resource_group>
      ```
      Replace <resource_group\> with the resource group you want to create the namespace in.

      To validate the namespace was created, run the following command.
      ``` Bash title="Validate namespace is created"
      ibmcloud cr namespace-list -v
      ```

      **3. Pull images from a registry to your local computer**

      Next, you can pull images from IBM Cloud Registry to your local computer. Make sure [Podman](https://podman.io/docs/installation){target="_blank"} is installed and up and running.

      ``` Bash title="Pull image to local computer"
      podman pull <source_image>:<tag>
      ```
      Replace <source_image\> with the respository of the image and <tag\> with the tag of the image that you want to use.

      Below is an example where <source_image\> is "hello-world" and <tag\> is "latest".

      ```
      podman pull hello-world:latest
      ```

      **4. Tag the image**

      Tags are used as an optional identifier to specify a particular version of an image.

      ``` Bash title="Tag image"
      podman tag <source_image>:<tag> <region>.icr.io/<my_namespace>/<new_image_repo>:<new_tag>
      ```
      Replace <source_image\> with the respository of the image, <tag\> with the tag of your local image that you previously pulled, <region\> with the name of your region, and <my_namespace\> with the namespace you created in step 2. You'll want to define the repository and tag of the image that you want to use in your namespace by replacing <new_image_repo\> and <new_tag\> respectively.

      Below is an example where <source_image\> is "hello-world", <tag\> is "latest", <region\> is "uk", <my_namespace\> is "namespace1", <new_image_repo\> is "hw_repo", and <new_tag\> is "1".

      ```
      podman tag hello-word:latest uk.icr.io/namespace1/hw_repo:1
      ```

      **5. Push images to your namespace**

      First, you'll need to log in to IBM Cloud Container Registry.

      ``` Bash title="Log in to ICR"
      ibmcloud cr login --client podman
      ```

      Once you've logged in, you can push the image up to your namespace in the registry.

      ``` Bash title="Push image to your namespace"
      podman push <region>.icr.io/<my_namespace>/<image_repo>:<tag>
      ```

      Replace <my_namespace\> with the namespace you created in step 2 and <image_repo\> and <tag\> with the repository and tag of the image you chose when you tagged the image in step 4.

      Below is an example where <region\> is "uk", <my_namespace\> is "namespace1", <image_repo\> is "hw_repo", and <tag\> is "1".

      ```
      podman push uk.icr.io/namespace1/hw_repo:1
      ```

      **6. Verify that the image was pushed**

      Verify that the image was pushed successfully by running the comand below.

      ```
      ibmcloud cr image-list
      ```

      You can also view your pushed images by clicking on the button below:

      [Images](https://cloud.ibm.com/containers/registry/images){ .md-button target="_blank"}

=== "Docker"

      **1. Install the Container Registry CLI**

      Before you begin, you need to install the IBM Cloud CLI so that you can run the IBM Cloud ***ibmcloud*** commands.
      ``` Bash title="Install the container-registry CLI"
      ibmcloud plugin install container-registry
      ```

      **2. Set up a namespace**

      Then, you need to create a namespace. The namespace is created in the resource group that you specify so that you can configure access to resources within the namespace at the resource group level. If you don't specify a resource group, then the default is used.
      ``` Bash title="Log in to IBM Cloud"
      ibmcloud login
      ```

      ``` Bash title="Create namespace"
      ibmcloud cr namespace-add <my_namespace>
      ```
      Make sure to replace <my_namespace\> with your preferred namespace.

      If you want to create the namespace in a specific resource group, use the following code **before** creating the namespace.
      ``` Bash title="Specify a resource group"
      ibmcloud target -g <resource_group>
      ```
      Replace <resource_group\> with the resource group you want to create the namespace in.

      To validate the namespace was created, run the following command.
      ``` Bash title="Validate namespace is created"
      ibmcloud cr namespace-list -v
      ```

      **3. Pull images from a registry to your local computer**

      Next, you can pull images from IBM Cloud Registry to your local computer. Make sure [Docker](https://www.docker.com/products/container-runtime/#/download){target="_blank"} is installed and up and running.

      ``` Bash title="Pull image to local computer"
      docker pull <source_image>:<tag>
      ```
      Replace <source_image\> with the respository of the image and <tag\> with the tag of the image that you want to use.

      Below is an example where <source_image\> is "hello-world" and <tag\> is "latest".

      ```
      docker pull hello-world:latest
      ```

      **4. Tag the image**

      Tags are used as an optional identifier to specify a particular version of an image.

      ``` Bash title="Tag image"
      docker tag <source_image>:<tag> <region>.icr.io/<my_namespace>/<new_image_repo>:<new_tag>
      ```
      Replace <source_image\> with the respository of the image, <tag\> with the tag of your local image that you previously pulled, <region\> with the name of your region, and <my_namespace\> with the namespace you created in step 2. You'll want to define the repository and tag of the image that you want to use in your namespace by replacing <new_image_repo\> and <new_tag\> respectively.

      Below is an example where <source_image\> is "hello-world", <tag\> is "latest", <region\> is "uk", <my_namespace\> is "namespace1", <new_image_repo\> is "hw_repo", and <new_tag\> is "1".

      ```
      docker tag hello-word:latest uk.icr.io/namespace1/hw_repo:1
      ```

      **5. Push images to your namespace**

      First, you'll need to log in to IBM Cloud Container Registry.

      ``` Bash title="Log in to ICR"
      ibmcloud cr login --client docker
      ```

      Once you've logged in, you can push the image up to your namespace in the registry.

      ``` Bash title="Push image to your namespace"
      docker push <region>.icr.io/<my_namespace>/<image_repo>:<tag>
      ```

      Replace <my_namespace\> with the namespace you created in step 2 and <image_repo\> and <tag\> with the repository and tag of the image you chose when you tagged the image in step 4.

      Below is an example where <region\> is "uk", <my_namespace\> is "namespace1", <image_repo\> is "hw_repo", and <tag\> is "1".

      ```
      docker push uk.icr.io/namespace1/hw_repo:1
      ```

      **6. Verify that the image was pushed**

      Verify that the image was pushed successfully by running the comand below.

      ```
      ibmcloud cr image-list
      ```

      You can also view your pushed images by clicking on the button below:

      [Images](https://cloud.ibm.com/containers/registry/images){ .md-button target="_blank"}

[Learn More about Quay :fontawesome-brands-redhat:](https://docs.redhat.com/en/documentation/red_hat_quay/3.5/html/deploy_red_hat_quay_for_proof-of-concept_non-production_purposes/pr01){ .md-button target="\_blank"} [Learn More about ICR :fontawesome-solid-cloud:](https://cloud.ibm.com/docs/Registry?topic=Registry-getting-started&interface=ui){ .md-button target="\_blank"}
