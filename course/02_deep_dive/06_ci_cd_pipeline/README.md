# Adding Terraform to a CI/CD pipeline
Modulo 8

## Terminology
### Continuous Integration

> When code is checked in a repository, contiunous integration is going to run some processes against that to check that the code is valid and then potentially merge into an existing branch.

### Continuous Delivery

> Delivery implies that you have the build artifacts ready and you can deploy that build when necessary

*Obs:* Continuous Deployment would be an additional step

###

* Automated testing and validation
* Multiple environments
  * Development, UAT, QA, Production

## Automation Toolset

- Github for SCM (Source Control Management)
- Jenkins for CI/CD
- Consul for Config Data

**Jenkins pipeline (stages):**
1. Code check-in (trigger this entire build process)
2. Init
3. Validate
4. Plan (agains our target environment)
5. Approve (manual, someone needs to approve)
6. Apply

## Jenkins Setup

- [ ] Install Jenkins as a traditional app
- [x] Deploy Jenkins in a container
- [ ] Deploy Jenkins in the cloud

### Configure access for Jenkins

Run the following commands to create the ACLs for Jenkins to access Consul Resources:

```
# Set Consul token with the bootstrap SecretId (returned by consul acl bootstrap)
export CONSUL_HTTP_TOKEN="f9985cb0-d1ab-1eac-3b15-d6039cb54859"

# Then, create a ACL for access keys under "networking"
consul acl token create -policy-name=networking -description="Jenkins networking"

# And one for access keys under "applications"
consul acl token create -policy-name=applications -description="Jenkins applications"
```

They will generate outputs as the following:
```
# For "Jenkins networking"
AccessorID:       cd1ac178-647d-f9dd-61bc-46545d4bfc99
SecretID:         01cb001a-944e-f450-fa19-a3a230801f35
Description:      Jenkins networking
Local:            false
Create Time:      2023-06-20 21:57:47.007838 -0300 -03
Policies:
   40a17f14-d89f-bed1-5c8b-48a3c4f16cee - networking
```

```
# For "Jenkins applications"
AccessorID:       f0243e3b-501e-eeed-924a-fa50b90c8a8b
SecretID:         e6835d3f-2dac-f957-eebd-2a090fa37bd6
Description:      Jenkins applications
Local:            false
Create Time:      2023-06-20 22:00:57.215672 -0300 -03
Policies:
   29abeafa-4ede-bf22-3f64-08a99178b5dd - applications
```

**Obs:** make note of SecretId for both tokens, it will be used later

### Create Jenkins container

```
docker pull jenkins/jenkins:lts

docker run -p 8080:8080 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home --name jenkins jenkins/jenkins:lts
```

After container initializing process is complete, Jenkins will print an admin password in the console, that we will use to access the UI. Access the container logs to pick up the credential:
```
docker logs jenkins
```

The output looks like this:
```
*************************************************************
*************************************************************

Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

d7b15bb9effc4ebaa97f31097feafdc8

This may also be found at: /var/jenkins_home/secrets/initialAdminPassword

*************************************************************
*************************************************************
*************************************************************

2023-06-21 01:04:29.271+0000 [id=33]	INFO	jenkins.InitReactorRunner$1#onAttained: Completed initialization
2023-06-21 01:04:29.285+0000 [id=23]	INFO	hudson.lifecycle.Lifecycle#onReady: Jenkins is fully up and running
2023-06-21 01:04:30.008+0000 [id=49]	INFO	h.m.DownloadService$Downloadable#load: Obtained the updated data file for hudson.tasks.Maven.MavenInstaller
2023-06-21 01:04:30.009+0000 [id=49]	INFO	hudson.util.Retrier#start: Performed the action check updates server successfully at the attempt #1
```

### Configuring

Access UI at [localhost:8080](http://localhost:8080).

Enter the admim password.

Install sugested plugins.

Configure our user.

Install Terraform plugin (Manage Jenkins > Manage Plugins > Available Plugins > search for Terraform and install it without restart)

Then install Terraform binary (Manage Jenkins > Global Tool Configuration > Add Terraform with the same name, that could include version > Select Version)

Add credentials (Control panel > Manage Jenkins > Credentials) under "(global)" as `Secret text`:
- networking_consul_token 
- applications_consul_token
- aws_access_key
- aws_secret_access_key

**Obs:** use the names above as the `ID` and the secret values as the `Secret`, that are the names of the fields in Jenkins console.

## Terraform Automation Environment Variables

Terraform have some variables to enhance automation process. Some of then are:
- `TF_IN_AUTOMATION = TRUE`: if set to **any value**, that reduce the amount of output, since no human beings will be watching the results
- `TF_LOG = "INFO"`
- `TF_LOG_PATH = "tf_log_MMDDYY_hhmmss`
- `TF_INPUT = FALSE`, that is useful for commands like `destroy`, that expects a `yes` from the user. So.. it forces to does not wait for a user input
- `TF_CLI_ARGS = "-input=false"` will apply these arguments to every time you run Terraform within the context of that build

Another variable that is important, but not necessarily related to automatino is:
- `TF_VAR_name`: where `name` is the name of some another variable. This sets the value for this variable, instead of wait for a value from user input

## About the Terraform config files we have here

Some important points:
- In the [backend](./backend.tf) we're using `host.docker.internal:8500`, instead of the `127.0.0.1:8500` that was used in other modules (in order to resolve the Consul address in the host, since Jenkins is running in a container)
- AWS provider needs to use credentials from environment variables, instead of use the profile attribute

## Jenkins file

We will be using the [Jenkinsfile](./Jenkinsfile) for set up the pipeline.

This file declare the pipeline that we want to run and its stored with the code that will be running.

**Obs:** attention on the points that may need to be adjusted in the code:
- TF_HOME should point to the Terraform tool crated in the Jenkins portal, with the same name that was set there
- dir('<PATH>') should use the full path for the configuration files (`.tf` files) that will be applied, **by accessing from the root of the source code**

## Createing the pipeline in Jenkins

Control panel > New task > (give it a name, such as `net-deploy`) > Pipeline (the type of item we want to create)

In the pipeline config page:
Definitions (scroll down a little bit and look for script) > Pipeline script from SCM (Source Control Management):
- SCM: Git
- Repository: the http url for clone (in this case is: https://github.com/pedrofgd/terraform-playground.git)
- Credentials: not needed for this case, because the repo is public
- Branch: */main (in this case)
- Script Path: course/02_deep_dive/06_ci_cd_pipeline/networking/Jenkinsfile

Use `Build now` to create a new build (run the pipeline)