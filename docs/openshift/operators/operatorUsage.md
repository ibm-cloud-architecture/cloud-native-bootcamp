# How to use Operators

Operators extend Kubernetes functionality by automating the deployment and management of complex applications. This guide walks you through the process of finding, installing, and using Operators in your OpenShift cluster.

## Installing an Operator

There are two primary ways to install Operators in OpenShift: through the web console and through the CLI.

### Installing via the Web Console

1. **Navigate to OperatorHub**
   - Log in to the OpenShift web console
   - Go to **Operators** → **OperatorHub**

2. **Find the Operator**
   - Use the search bar to find your desired Operator
   - Filter by category, source, or capability level

3. **Review Operator Details**
   - Click on the Operator to view its description
   - Review the provided APIs (Custom Resources)
   - Check the documentation and prerequisites

4. **Install the Operator**
   - Click **Install**
   - Choose the installation mode:
     - **All namespaces** - Operator watches all namespaces
     - **Specific namespace** - Operator watches only the selected namespace
   - Select the update channel and approval strategy
   - Click **Install**

5. **Verify Installation**
   - Navigate to **Operators** → **Installed Operators**
   - Confirm the Operator status shows "Succeeded"

### Installing via the CLI

Create a `Subscription` resource to install an Operator:

```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: my-operator
  namespace: openshift-operators
spec:
  channel: stable
  name: my-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  installPlanApproval: Automatic
```

Apply the subscription:

```bash
oc apply -f subscription.yaml
```

Verify the installation:

```bash
# Check the subscription status
oc get subscription my-operator -n openshift-operators

# Check the ClusterServiceVersion (CSV)
oc get csv -n openshift-operators

# Check the Operator pod
oc get pods -n openshift-operators
```

## Creating Custom Resources

Once an Operator is installed, you can create instances of the applications it manages using Custom Resources (CRs).

### Finding Available APIs

Each Operator provides one or more Custom Resource Definitions (CRDs). To see what APIs an Operator provides:

```bash
# List CRDs installed by Operators
oc get crd | grep <operator-name>

# Describe a specific CRD
oc describe crd <crd-name>
```

### Creating a Custom Resource via Web Console

1. Go to **Operators** → **Installed Operators**
2. Click on the installed Operator
3. Navigate to the desired API tab
4. Click **Create** and fill in the form or edit the YAML

### Creating a Custom Resource via CLI

Example: Creating a PostgreSQL cluster with the Crunchy PostgreSQL Operator:

```yaml
apiVersion: postgres-operator.crunchydata.com/v1beta1
kind: PostgresCluster
metadata:
  name: my-postgres
  namespace: my-project
spec:
  postgresVersion: 15
  instances:
    - name: instance1
      replicas: 2
      dataVolumeClaimSpec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 10Gi
  backups:
    pgbackrest:
      repos:
        - name: repo1
          volume:
            volumeClaimSpec:
              accessModes:
                - ReadWriteOnce
              resources:
                requests:
                  storage: 5Gi
```

Apply the custom resource:

```bash
oc apply -f postgres-cluster.yaml
```

## Managing Operator Instances

### Viewing Custom Resources

```bash
# List all instances of a custom resource type
oc get <resource-type> -n <namespace>

# Example: List all PostgresClusters
oc get postgresclusters -n my-project

# Get detailed information
oc describe <resource-type> <resource-name> -n <namespace>
```

### Updating Custom Resources

Modify the custom resource to update the managed application:

```bash
# Edit directly
oc edit <resource-type> <resource-name> -n <namespace>

# Or apply an updated YAML file
oc apply -f updated-resource.yaml
```

### Deleting Custom Resources

```bash
oc delete <resource-type> <resource-name> -n <namespace>
```

The Operator will automatically clean up all associated resources.

## Managing Operator Subscriptions

### Viewing Subscriptions

```bash
# List all subscriptions
oc get subscriptions -A

# Get subscription details
oc describe subscription <name> -n <namespace>
```

### Updating an Operator

If using manual approval, approve pending updates:

```bash
# Find the InstallPlan
oc get installplan -n <namespace>

# Approve the InstallPlan
oc patch installplan <installplan-name> -n <namespace> \
  --type merge --patch '{"spec":{"approved":true}}'
```

### Changing Update Channel

```bash
oc patch subscription <name> -n <namespace> \
  --type merge --patch '{"spec":{"channel":"<new-channel>"}}'
```

## Uninstalling an Operator

### Step 1: Delete Custom Resources

First, delete all instances managed by the Operator:

```bash
oc delete <resource-type> --all -n <namespace>
```

### Step 2: Delete the Subscription

```bash
oc delete subscription <operator-name> -n <namespace>
```

### Step 3: Delete the ClusterServiceVersion

```bash
oc delete csv <csv-name> -n <namespace>
```

### Step 4: (Optional) Delete CRDs

If no longer needed, delete the Custom Resource Definitions:

```bash
oc delete crd <crd-name>
```

## Troubleshooting Operators

### Check Operator Logs

```bash
# Find the Operator pod
oc get pods -n <operator-namespace>

# View logs
oc logs <operator-pod> -n <operator-namespace>
```

### Check Events

```bash
# Namespace events
oc get events -n <namespace>

# Events for a specific resource
oc describe <resource-type> <resource-name> -n <namespace>
```

### Common Issues

| Issue | Possible Cause | Solution |
| ----- | -------------- | -------- |
| Operator stuck in "Pending" | Missing dependencies | Check InstallPlan for required resources |
| Custom Resource not reconciling | Operator not running | Check Operator pod status and logs |
| Installation failed | Insufficient permissions | Verify RBAC and cluster admin access |
| Upgrade blocked | Manual approval required | Approve the pending InstallPlan |

## Best Practices

1. **Start with a test namespace** - Test Operators in non-production before deploying widely
2. **Use specific versions** - Pin to specific channels for production stability
3. **Monitor Operator health** - Set up alerts for Operator pod failures
4. **Review RBAC** - Understand what permissions the Operator requires
5. **Plan for upgrades** - Use manual approval in production for controlled upgrades
6. **Clean up properly** - Always delete CRs before uninstalling Operators
