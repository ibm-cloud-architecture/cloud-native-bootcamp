# Cloud Native Challenge

## Phase 1 - Local Develop

- Start by creating a Github Repo for your application.
- Choose `NodeJS`, `Python`, or `React`.
- Site about one of the following:
    - Yourself
    - Hobby
    - Place you live
- Must be able to run locally
  
### Application Requirements

- Minimum of 3 webpages
- Minimum of 1 GET and POST method each.
- SwaggerUI Configured for API Testing.
- API's exposed through Swagger
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

- Create a DockerFile
- Build your docker image from the dockerfile
- Run it locally via Docker Desktop or another docker engine.

### Image Registries

- Once validation of working docker image, push the image up to a registry.
- Use one of the following registries:
    - Docker
    - Quay.io
    - IBM Container
- Push the image up with the following name: ```{DockerRegistry}/{yourusername}/techdemos-cn:v1```

## Phase 4 - Kubernetes Ready

### Create Pod and Deployment files

- Create a `Pod` YAML to validate your image.
- Next, create a `deployment` yaml file with the setting of 3 replicas.
- Verify starting of deployment
- Push all YAML files to Github

### Application Exposing

- Create a `Service` and `Route` yaml
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

### GitsOps Configuration

- Use ArgoCD to setup Deployment.
- Test your ArgoCD deployment
  - Make a change to site and push them.
- Validate new image version.

## Extras

### Chatbot Functions

- Watson Assistant Integration
- Conversation about your sites topic.
- Have Chat window or page.
- Integrate Watson Assistant Actions.