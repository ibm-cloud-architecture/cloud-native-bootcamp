# Cloud Native Challenge

## Phase 1 - Local Develop

- Start by creating a Github Repo for your application.
- Choose a stack you want to learn, for example `Node.js`, `Python`, `Go`, `Java` (Quarkus or Spring Boot), or a `React` front end with an API back end.
- Site about one of the following:
    - Yourself
    - Hobby
    - Place you live
- Must be able to run locally
  
### Application Requirements

- Minimum of 3 webpages
- Minimum of 1 GET and POST method each.
- An OpenAPI specification for your API, with Swagger UI configured for testing it.
- A `/healthz` endpoint that Kubernetes probes can call.
- Custom CSS files for added formatting.
  
### Testing

Setup each of the following tests that apply:

- Page tests
- API tests
- Connection Tests

## Phase 2 - Application Enhancements

### Database Connectivity and Functionality

- Add local or cloud DB to use for data collection.
- Use 3rd party API calls to get data.
    - Post Data to DB via API Call
    - Retrieve Data from DB via API Call
    - Delete Data from DB via API Call

## Phase 3 - Containerize

### Container Image

- Create a `Containerfile` (or `Dockerfile`). Use a multi-stage build and a small base image such as UBI minimal.
- Make the image run as a non-root user and work with any UID, as OpenShift requires.
- Build your image with Podman (or Docker).
- Run it locally with `podman run` and test it.

### Image Registries

- Once your image works, push it to a registry. Build it for `linux/amd64`, or build a multi-arch image, if you're on an Apple Silicon Mac.
- Use one of the following registries:
    - Quay.io
    - GitHub Container Registry (ghcr.io)
    - Docker Hub
    - IBM Cloud Container Registry
- Push the image up with the following name: ```{registry}/{yourusername}/techdemos-cn:v1```

## Phase 4 - Kubernetes Ready

### Create Pod and Deployment files

- Create a `Pod` YAML to validate your image.
- Next, create a `deployment` yaml file with the setting of 3 replicas, liveness and readiness probes, and resource requests and limits.
- Verify starting of deployment
- Push all YAML files to Github

### Application Exposing

- Create a `Service` and a `Route` (or `Ingress`) yaml
- Save `Service` and `Route` yamls in Github

### Configuration Setup

- Create a `ConfigMap` for all site configuration.
- Setup `Secrets` for API keys or Passwords to 3rd parties.
- Add storage where needed to deployment.

## Phase 5 - Devops/Gitops

### Tekton Pipeline Setup

- Create a Tekton pipeline to do the following:
    - Setup
    - Test
    - Build and Push Image
    - GitOps Version Update
- Make each of the above their own task.
- Setup triggers to respond to Github commits and PR's

### GitOps Configuration

- Use Argo CD (OpenShift GitOps) to deploy from a Git repository.
- Test your Argo CD deployment
  - Make a change to site and push them.
- Validate new image version.

## Extras

### Chatbot Functions

- Integrate an AI assistant, for example IBM watsonx Assistant or an LLM through watsonx.ai
- Conversation about your sites topic.
- Have Chat window or page.
- Integrate Watson Assistant Actions.