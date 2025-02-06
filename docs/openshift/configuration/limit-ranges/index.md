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

### Container Limits

```
apiVersion: "v1"
kind: "LimitRange"
metadata:
  name: "resource-limits" [1]
spec:
  limits:
    - type: "Container"
      max:
        cpu: "2" [2]
        memory: "1Gi" [3]
      min:
        cpu: "100m" [4]
        memory: "4Mi" [5]
      default:
        cpu: "300m" [6]
        memory: "200Mi" [7]
      defaultRequest:
        cpu: "200m" [8]
        memory: "100Mi" [9]
      maxLimitRequestRatio:
        cpu: "10" [10]
```

[1] The name of the _LimitRange_ object

[2] The maximum amount of CPU that a single container in a pod can request

[3] The maximum amount of memory that a single container in a pod can request

[4] The minimum amount of CPU that a single container in a pod can request

[5] The minimum amount of memory that a single container in a pod can request

[6] The default amount of CPU that a container can use if not specified in the _Pod_ spec

[7] The default amount of memory that a container can use if not specified in teh _Pod_ spec

[8] The default amount of CPU that a contianer can request if not specified in the _Pod_ spec

[9] The default amount of memory that a container can request if not specified in the _Pod_ spec

[10] The maximum limit-to-request ratio for a container

### Pod Limits

```
apiVersion: "v1"
kind: "LimitRange"
metadata:
  name: "resource-limits" [1]
spec:
  limits:
    - type: "Pod"
      max:
        cpu: "2" [2]
        memory: "1Gi" [3]
      min:
        cpu: "200m" [4]
        memory: "6Mi" [5]
      maxLimitRequestRatio:
        cpu: "10" [6]
```

[1] The name of the _LimitRange_ object

[2] The maximum amount of CPU that a pod can request across all containers

[3] The maximum amount of memory that a pod can request across all containers

[4] The minimum amount of CPU that a pod can request across all containers

[5] The minimum amount of memory that a pod can request across all containers

[6] The maximum limit-to-request ration for a container

### Image Limits

```
apiVersion: "v1"
kind: "LimitRange"
metadata:
  name: "resource-limits" [1]
spec:
  limits:
    - type: openshift.io/Image
      max:
        storage: 1Gi [2]
```

[1] The name of the _LimitRange_ object

[2] The maximum size of an image that can be pushed to a registry

### Image Stream Limits

```
apiVersion: "v1"
kind: "LimitRange"
metadata:
  name: "resource-limits" [1]
spec:
  limits:
    - type: openshift.io/ImageStream
      max:
        openshift.io/image-tags: 20 [2]
        openshift.io/images: 30 [3]
```

[1] The name of the _LimitRange_ object

[2] The maximum number of unique image tags in the _imagestream.spec.tags_ parameter in _imagestream_ spec

[3] The maximum number of unique image regerenes in the _imagestream.status.tags_ parameter in the _imagestream_ spec

### Persistent Volume Claim Limits

```
apiVersion: "v1"
kind: "LimitRange"
metadata:
  name: "resource-limits" [1]
spec:
  limits:
    - type: "PersistentVolumeClaim"
      min:
        storage: "2Gi" [2]
      max:
        storage: "50Gi" [3]
```

[1] The name of the _LimitRange_ object

[2] The minimum amount of storage that can be requested in a persistent volume claim

[3] The maximum amount of storage that can be requested in a persistent volume claim
