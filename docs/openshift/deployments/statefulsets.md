# StatefulSets

StatefulSets are workload API objects used to manage stateful applications. Unlike Deployments, StatefulSets maintain a sticky identity for each pod and provide guarantees about the ordering and uniqueness of these pods.

StatefulSets are valuable for applications that require one or more of the following:

- Stable, unique network identifiers
- Stable, persistent storage
- Ordered, graceful deployment and scaling
- Ordered, automated rolling updates

## How StatefulSets Work

StatefulSets create pods with predictable names following the pattern `{statefulset-name}-{ordinal}`. For example, a StatefulSet named `mysql` with 3 replicas creates pods: `mysql-0`, `mysql-1`, `mysql-2`.

**Key Characteristics:**

- Pods are created sequentially (0, 1, 2...) and terminated in reverse order
- Each pod gets a stable DNS hostname: `{pod-name}.{service-name}.{namespace}.svc.cluster.local`
- PersistentVolumeClaims are retained when pods are deleted (data persists)
- Scaling down does not delete associated PVCs

## When to Use StatefulSets

| Use Case | Examples |
|----------|----------|
| Databases | MySQL, PostgreSQL, MongoDB |
| Message Queues | Kafka, RabbitMQ |
| Distributed Systems | Elasticsearch, Cassandra, Zookeeper |
| Applications requiring stable network identity | Leader election scenarios |

## Resources

=== "OpenShift"

    [StatefulSets :fontawesome-solid-database:](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/workloads_apis/statefulset-apps-v1){ .md-button target="_blank"}

=== "Kubernetes"

    [StatefulSets :fontawesome-solid-database:](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/){ .md-button target="_blank"}

    [StatefulSet Basics :fontawesome-solid-database:](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/){ .md-button target="_blank"}

## References

_Headless Service for StatefulSet (required for stable network identities)_

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  ports:
    - port: 3306
      name: mysql
  clusterIP: None  # Headless service
  selector:
    app: mysql
```

_Secret with the MySQL root password_

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
stringData:
  password: changeme
```

_StatefulSet Definition_

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: "mysql"
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:8.4
          ports:
            - containerPort: 3306
              name: mysql
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: password
          readinessProbe:   # the next replica starts only when this one is ready
            exec:
              command: ["sh", "-c", "mysqladmin ping -uroot -p\"$MYSQL_ROOT_PASSWORD\""]
            initialDelaySeconds: 10
            periodSeconds: 5
          resources:
            requests:
              cpu: 250m
              memory: 512Mi
          volumeMounts:
            - name: data
              mountPath: /var/lib/mysql
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        # No storageClassName: the cluster's default StorageClass is used
        resources:
          requests:
            storage: 1Gi
```

!!! note
    This StatefulSet runs three **independent** MySQL servers, each with its own name (`mysql-0`, `mysql-1`, `mysql-2`), DNS entry (`mysql-0.mysql`) and volume. A StatefulSet provides stable identity, ordering and storage. It doesn't set up replication between the instances. For replicated databases, use an operator, for example from OperatorHub.

=== "OpenShift"

    ``` Bash title="Create StatefulSet"
    oc apply -f statefulset.yaml
    ```

    ``` Bash title="Get StatefulSets"
    oc get statefulsets
    ```

    ``` Bash title="Describe StatefulSet"
    oc describe statefulset mysql
    ```

    ``` Bash title="Scale StatefulSet"
    oc scale statefulset mysql --replicas=5
    ```

    ``` Bash title="Delete StatefulSet (keeps PVCs)"
    oc delete statefulset mysql
    ```

    ``` Bash title="Delete StatefulSet and PVCs"
    oc delete statefulset mysql --cascade=foreground
    oc delete pvc -l app=mysql
    ```

=== "Kubernetes"

    ``` Bash title="Create StatefulSet"
    kubectl apply -f statefulset.yaml
    ```

    ``` Bash title="Get StatefulSets"
    kubectl get statefulsets
    ```

    ``` Bash title="Describe StatefulSet"
    kubectl describe statefulset mysql
    ```

    ``` Bash title="Scale StatefulSet"
    kubectl scale statefulset mysql --replicas=5
    ```

    ``` Bash title="Delete StatefulSet (keeps PVCs)"
    kubectl delete statefulset mysql
    ```

    ``` Bash title="Delete StatefulSet and PVCs"
    kubectl delete statefulset mysql --cascade=foreground
    kubectl delete pvc -l app=mysql
    ```

## StatefulSet vs Deployment

| Feature | Deployment | StatefulSet |
|---------|------------|-------------|
| Pod Names | Random (e.g., `nginx-5d4c6f7b8-x2k9j`) | Predictable (e.g., `mysql-0`) |
| Pod Creation | Parallel | Sequential |
| Pod Deletion | Any order | Reverse order |
| Network Identity | Ephemeral | Stable DNS |
| Storage | Shared PVC | Per-pod PVC |
| Use Case | Stateless apps | Stateful apps |
