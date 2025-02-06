# Limit Ranges

In an OpenShift Container Platform cluster, containers run with unlimited compute resources. By using limit ranges, you can restrict the amount of resources consumed for the following objects within a project.

- Pods/Containers: You can set minimum and maximum requirements for CPU and memory

- Image Streams: You can set limits on the number of images and tags in an _ImageStream_ object

- Images: You can limit the size of images that can be pushed to a registry

- Persistent Volume Claims (PVC): You can restrict the size of the PVCs that can be requested

A _LimitRange_ object allows you to restrict the amount of resources that can be consumed in a project. Any request that is made to create or modify a resource will be validated against any _LimitRange_ objects in the project. If any of the constraints listed in the _LimitRange_ object are violated, then the resource request is rejected.

## Creating a Limit Range

To create a _LimitRange_ object you can follow the example below:

```
apiVersion: "v1"
kind: "LimitRange"
metadata:
  name: "resource-limits"
spec:
  limits:
    - type: "Pod"
      max:
        cpu: "2"
        memory: "1Gi"
      min:
        cpu: "200m"
        memory: "6Mi"
    - type: "Container"
      max:
        cpu: "2"
        memory: "1Gi"
      min:
        cpu: "100m"
        memory: "4Mi"
      default:
        cpu: "300m"
        memory: "200Mi"
      defaultRequest:
        cpu: "200m"
        memory: "100Mi"
      maxLimitRequestRatio:
        cpu: "10"
    - type: openshift.io/Image
      max:
        storage: 1Gi
    - type: openshift.io/ImageStream
      max:
        openshift.io/image-tags: 20
        openshift.io/images: 30
    - type: "PersistentVolumeClaim"
      min:
        storage: "2Gi"
      max:
        storage: "50Gi"
```
