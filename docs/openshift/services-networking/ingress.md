# Ingress

An API object that manages external access to the services in a cluster, typically HTTP.

Ingress can provide load balancing, SSL termination and name-based virtual hosting.

Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.

## Resources

**OpenShift**
- [Ingress Operator](https://docs.openshift.com/container-platform/4.3/networking/ingress-operator.html)
- [Using Ingress Controllers](https://docs.openshift.com/container-platform/4.3/networking/configuring_ingress_cluster_traffic/configuring-ingress-cluster-traffic-ingress-controller.html)

**IKS**
- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
- [Minikube Ingress](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/)

## References

```yaml
apiVersion: networking.k8s.io/v1beta1 # for versions before 1.14 use extensions/v1beta1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
  - host: hello-world.info
    http:
      paths:
      - path: /
        backend:
          serviceName: web
          servicePort: 8080
```
<Tabs>
<Tab label="OpenShift">

** View Ingress Status **
```
oc describe clusteroperators/ingress
```
** Describe default Ingress Controller **
```
oc describe --namespace=openshift-ingress-operator ingresscontroller/default
```

</Tab>

<Tab label="IKS">

```
minikube addons enable ingress
```
```
kubectl get pods -n kube-system | grep ingress
```
```
kubectl create deployment web --image=bitnami/nginx
```
```
kubectl expose deployment web --name=web --port 8080
```
```
kubectl get svc web
```
```
minikube service --url web
```
```
kubectl get ingress
```
```
kubcetl describe ingress example-ingress
```
```
curl hello-world.info --resolve hello-world.info:80:<ADDRESS>
```

</Tab>

</Tabs>