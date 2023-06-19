# Continuous Integration

Continuous Integration, Delivery, and Deployment are important devOps practices and we often hear a lot about them. These processes are valuable and ensures that the software is up to date timely.

- **Continuous Integration** is an automation process which allows developers to integrate their work into a repository. When a developer pushes his work into the source code repository, it ensures that the software continues to work properly. It helps to enable collaborative development across the teams and also helps to identify the integration bugs sooner.
- **Continuous Delivery** comes after Continuous Integration. It prepares the code for release. It automates the steps that are needed to deploy a build.
- **Continuous Deployment** is the final step which succeeds Continuous Delivery. It automatically deploys the code whenever a code change is done. Entire process of deployment is automated.

## Tekton Overview

Tekton is a cloud-native solution for building CI/CD systems. It consists of Tekton Pipelines, which provides the building blocks, and of supporting components, such as Tekton CLI and Tekton Catalog, that make Tekton a complete ecosystem.

## Resources

[Tekton Overview :fontawesome-regular-file-pdf:](../materials/04-Tekton-Overview.pdf){ .md-button }
[IBM Cloud DevOps with Tekton :fontawesome-regular-file-pdf:](../materials/10-IBM-Cloud-DevOps.pdf){ .md-button }

## Activities

The continuous integration activities focus around Tekton the integration platform. These labs will show you how to build pipelines and test your code before deployment.

These tasks assume that you have:

- Reviewed the continuous integration concept page.
- Installed Tekton into your cluster.

| Task                            | Description         | Link        | Time    |
| --------------------------------| ------------------  |:----------- |---------|
| ***Walkthroughs***                         |         |         |     |
| Deploying Applications From Source |  Using OpenShift 4 | [S2I](https://learn.openshift.com/introduction/deploying-python/){:target="_blank"} | 30 min |
| ***Try It Yourself***                         |         |         |     |
| Tekton Lab | Using Tekton to build container images | [Tekton](labs/openshift.md) | 1 hour |
| IBM Cloud DevOps | Using IBM Cloud ToolChain with Tekton | [Tekton on IBM Cloud](../continuous-integration/activities/ibm-toolchain){:target="_blank"} | 1 hour |
| Jenkins Lab | Using Jenkins to build and deploy applications. | [Jenkins](../continuous-integration/activities/jenkins/openshift){:target="_blank"} | 1 hour |

Once you have completed these tasks, you will have an understanding of continuous integration and how to use Tekton to build a pipeline.
