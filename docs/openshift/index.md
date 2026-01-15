# What is Container Orchestration?

## Introduction

Kubernetes is an open source container orchestration platform that automates deployment, management and scaling of applications. Learn how Kubernetes enables cost-effective cloud native development.

## What is OpenShift?

Red Hat OpenShift is an open-source container platform that runs on the Red Hat enterprise Linux operating system and Kubernetes. It is typically referred to as a "Platform as a Service" (PaaS) due to its combination of services for enterprise businesses, including the Kubernetes platform and Docker container images. OpenShift offers additional features exclusive to its enterprise platform. It allows for deploying apps on highly available clusters and securing hybrid workloads with developer-focused tools and seamless integration of IBM, CloudPak, and Red Hat content.

Red Hat OpenShift provides a uniform platform across public and private clouds for full portability, standardization, and ease of adoption. It offers various forms to meet customer needs, such as Red Hat OpenShift Container Platform (OCP), Red Hat OpenShift Dedicated (OSD), Microsoft Azure Red Hat OpenShift, and Red Hat OpenShift Online.

In summary, Red Hat OpenShift is an enterprise-ready Kubernetes container platform with full-stack automated operations for managing hybrid cloud and multi-cloud deployments. It offers multiple offerings to cater to diverse customer requirements and ensures a consistent experience across public and private clouds.

## What is Kubernetes?

Kubernetes—also known as ‘k8s’ or ‘kube’—is a container orchestration platform for scheduling and automating the deployment, management, and scaling of containerized applications.

Kubernetes was first developed by engineers at Google before being open sourced in 2014.
It is a descendant of ‘Borg,’ a container orchestration platform used internally at Google. (Kubernetes is Greek for helmsman or pilot, hence the helm in the [Kubernetes logo](https://github.com/cncf/artwork/tree/master/projects/kubernetes).)

Today, Kubernetes and the broader container ecosystem are maturing into a general-purpose computing platform and ecosystem that rivals—if not surpasses—virtual machines (VMs) as the basic building blocks of modern cloud infrastructure and applications.
This ecosystem enables organizations to deliver a high-productivity [Platform-as-a-Service (PaaS)](https://www.ibm.com/cloud/learn/paas) that addresses multiple infrastructure- and operations-related tasks and issues surrounding [cloud native](https://www.ibm.com/cloud/learn/cloud-native) development so that development teams can focus solely on coding and innovation.     

<div class="grid cards" markdown>

-   :material-clock-fast:{ .lg .middle } __Learning Kubernetes__

    ---

    Learning Kubernetes through IBM Learning

    [:octicons-arrow-right-24: Getting started](https://www.ibm.com/cloud/learn/kubernetes){ .md-button target="_blank"}


</div>

<iframe width="560" height="315" src="https://www.youtube.com/embed/aSrqRSk43lY" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Presentations

[Kubernetes Overview :fontawesome-regular-file-pdf:](./materials/03-Kubernetes-Basics.pdf){ .md-button target="_blank"}

## Predictable Demands Pattern

An application's performance, efficiency, and behaviors are reliant upon it's ability to have the appropriate allocation of resources.  The Predictable Demands pattern is based on declaring the dependencies and resources needed by a given application.  The scheduler will prioritize an application with a defined set of resources and dependencies since it can better manage the workload across nodes in the cluster.  Each application has a different set of dependencies which we will touch on next.

### Runtime Dependencies
 
One of the most common runtime dependencies is the exposure of a container's specific port through hostPort.  Different applications can specify the same port through hostPort which reserves the port on each node in the cluster for the specific container.  This declaration restricts multiple containers with the same hostPort to be deployed on the same nodes in the cluster and restricts the scale of pods to the number of nodes you have in the cluster.  

Another runtime dependency is file storage for saving the application state.  Kubernetes offers Pod-level storage utilities that are capable of surviving container restarts.  Applications needing to read or write to these storage mechanisms will require nodes that is provided the type of volume required by the application.  If there is no nodes available with the required volume type, then the pod will not be scheduled to be deployed at all.

A different kind of dependency is configurations.  ConfigMaps are used by Kubernetes to strategically plan out how to consume it's settings through either environment variables or the filesystem.  Secrets are consumed the same was as a ConfigMap in Kubernetes.  Secrets are a more secure way to distribute environment-specific configurations to containers within the pod. 


### Resource Profiles

Resource Profiles are definitions for the compute resources required for a container.  Resources are categorized in two ways, compressible and incompressible.  Compressible resources include resources that can be throttled such as CPU or network bandwidth. Incompressible represents resouces that can't be throttled such as memory where there is no other way to release the allocated resource other than killing the container.  The difference between compressible and incompressible is very important when it comes to planning the deployment of pods and containers since the resource allocation can be affected by the limits of each.

Every application needs to have a specified minimum and maximum amount of resources that are needed.  The minimum amount is called "requests" and the maximum is the "limits".  The scheduler uses the requests to determine the assignment of pods to nodes ensuring that the node will have enough capacity to accommodate the pod and all of it's containers required resources.  An example of defined resource limits is below:

Different levels of Quality of Service (QoS) are offered based on the specified requests and limits.

### Quality of Service Levels

**Best Effort**
:   Lowest priority pod with no requests or limits set for its containers. These pods will be the first of any pods killed if resources run low.

**Burstable**
:   Limits and requests are defined but they are not equal. The pod will use the minimum amount of resources, but will consume more if needed up to the limit. If the needed resources become scarce then these pods will be killed if no Best Effort pods are left.

**Guaranteed**
:   Highest priority pods with an equal amount of requests and limits. These pods will be the last to be killed if resources run low and no Best Effort or Burstable pods are left. 

### Pod Priority

The priority of pods can be defined through a PriorityClass object. The PriorityClass object allows developers to indicate the importance of a pod relative to the other pods in the cluster.  The higher the priority number then the higher the priority of the pod. The scheduler looks at a pods priorityClassName to populate the priority of new pods.  As pods are being placed in the scheduling queue for deployment, the scheduler orders them from highest to lowest.

Another key feature for pod priority is the Preemption feature.  The Preemption feature occurs when there are no nodes with enough capacity to place a pod.  If this occurs the scheduler can preempt (remove) lower-priority Pods from nodes to free up resources and place Pods with higher priority.  This effectively allows system administrators the ability to control which critical pods get top priority for resources in the cluster as well as controlling which critical workloads are able to be run on the cluster first. If a pod can not be scheduled due to constraints it will continue on with lower-priority nodes.

Pod Priority should be used with caution for this gives users the ability to control over the kubernetes scheduler and ability to place or kill pods that may interrupt the cluster's critical functions.  New pods with higher priority than others can quickly evict pods with lower priority that may be critical to a container's performance.  ResourceQuota and PodDisruptionBudget are two tools that help combat this from happening read more here.

## Benefits of Container Orchestration

- **Simplified Operations** - Automates deployment, scaling, and management of containerized applications
- **High Availability** - Automatically restarts failed containers and reschedules them on healthy nodes
- **Scalability** - Easily scale applications up or down based on demand
- **Resource Optimization** - Efficiently allocates resources across the cluster to maximize utilization
- **Service Discovery and Load Balancing** - Built-in DNS and load balancing for container communication
- **Self-Healing** - Automatically replaces and reschedules containers when nodes fail
- **Rolling Updates and Rollbacks** - Deploy new versions with zero downtime and easily rollback if issues arise
- **Secret and Configuration Management** - Securely manage sensitive information and application configuration
