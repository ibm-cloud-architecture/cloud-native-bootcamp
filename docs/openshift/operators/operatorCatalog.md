# What is the Operator Catalog

The Operator Catalog, also known as OperatorHub, is a registry of Kubernetes Operators that have been packaged for easy discovery, installation, and lifecycle management. In Red Hat OpenShift, the Embedded OperatorHub provides a curated marketplace of Operators that have been verified to work with the platform.

## Understanding the Operator Catalog

The Operator Catalog serves as a central repository where cluster administrators and developers can browse, discover, and install Operators. It provides a standardized way to distribute and manage Operators across Kubernetes and OpenShift clusters.

### Key Features

- **Centralized Discovery** - Browse available Operators from a single interface
- **Verified Operators** - Access Operators that have been tested and certified
- **Easy Installation** - Install Operators with just a few clicks
- **Automatic Updates** - Subscribe to Operators for automatic version updates
- **Dependency Management** - Automatically handle Operator dependencies

## Types of Operator Sources

The Operator Catalog in OpenShift aggregates Operators from multiple sources:

### Red Hat Operators

Operators packaged and shipped by Red Hat. These are fully supported as part of an OpenShift subscription and include:

- Red Hat AMQ Streams
- Red Hat OpenShift Serverless
- Red Hat OpenShift Service Mesh
- Red Hat OpenShift Pipelines (Tekton)
- Red Hat OpenShift GitOps (ArgoCD)

### Certified Operators

Operators from independent software vendors (ISVs) that have been certified by Red Hat. These Operators have passed certification requirements and are supported by the vendor:

- MongoDB Enterprise
- Crunchy PostgreSQL
- Elasticsearch (ECK)
- Datadog
- Splunk

### Community Operators

Operators from the open-source community. These are not officially supported but provide access to a wide range of software:

- Prometheus Operator
- Grafana Operator
- Jaeger Operator
- Strimzi (Kafka)
- ArgoCD Community

### Custom Catalogs

Organizations can also create their own custom Operator catalogs to distribute internal Operators or curated collections of Operators.

## Accessing the Operator Catalog

### Through the OpenShift Web Console

1. Navigate to **Operators** → **OperatorHub** in the left menu
2. Browse or search for Operators
3. Filter by category, source, or capability level
4. Click on an Operator to view details and installation options

### Through the CLI

You can also interact with the Operator Catalog using the `oc` command:

```bash
# List available PackageManifests (Operators)
oc get packagemanifests -n openshift-marketplace

# Get details about a specific Operator
oc describe packagemanifest <operator-name> -n openshift-marketplace

# List CatalogSources
oc get catalogsources -n openshift-marketplace
```

## Operator Capability Levels

Operators in the catalog are classified by their capability level, indicating their maturity:

| Level | Name | Description |
| ----- | ---- | ----------- |
| 1 | Basic Install | Automated installation and configuration |
| 2 | Seamless Upgrades | Automated upgrades between versions |
| 3 | Full Lifecycle | Backup, restore, and failure recovery |
| 4 | Deep Insights | Metrics, alerts, and log processing |
| 5 | Auto Pilot | Horizontal/vertical scaling, auto-tuning |

## CatalogSource Custom Resource

The Operator Catalog is defined using `CatalogSource` custom resources. Each CatalogSource points to an index of Operators:

```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: my-operator-catalog
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: quay.io/my-org/my-operator-index:latest
  displayName: My Operator Catalog
  publisher: My Organization
  updateStrategy:
    registryPoll:
      interval: 30m
```

## Managing Catalog Sources

### Viewing Available Catalogs

```bash
oc get catalogsources -n openshift-marketplace
```

Default catalogs in OpenShift include:

- `certified-operators` - Red Hat certified Operators
- `community-operators` - Community Operators
- `redhat-marketplace` - Red Hat Marketplace Operators
- `redhat-operators` - Red Hat Operators

### Disabling Default Catalogs

In restricted environments, you may need to disable default catalogs:

```bash
oc patch OperatorHub cluster --type json \
  -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
```

## Best Practices

1. **Use certified Operators** when possible for production workloads
2. **Review Operator permissions** before installation
3. **Test Operators** in non-production environments first
4. **Monitor Operator health** after deployment
5. **Keep Operators updated** by subscribing to automatic updates
