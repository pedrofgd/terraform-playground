# 

Curso: [Pluralsight: Terraform Deep Dive by Ned Bellavance](https://app.pluralsight.com/library/courses/terraform-deep-dive/table-of-contents)

[Github repository by ned1313](https://github.com/ned1313/Deep-Dive-Terraform)

## Course Overview

### Resources needed

- [x] Terraform CLI
- [x] AWS CLI
- [x] AWS account

### Additional Technologies

- Amazon Web Services
- Docker
- [Jenkins](https://www.jenkins.io/)
- Ansible
- [Consul](https://www.consul.io/) by HashiCorp
  - Storage of remote state and storage of configuration data pulled in as a data source by Terraform

:warning: we will not be using Terraform Cloud
* Terraform Cloud can be use to store state and credentials and much more

### Course Content

- Import existing resources
- Managing state data
  - Move to remote location
- Workspaces and collaboration
- Data sources and templates
- Adding and CI/CD pipeline
- Integrate with config managers

## Terraform Import command

- No automatic import, yet (updated 04 jan 2023)
- Update configuration to include resources
- Match up identifiers for provider and configuration
- Adds new resources to the state

`terraform import [options] ADDR ID`

* ADDR configuration resource identifier
  * Ex: `module.vpc.aws_subnet.public[2]`

* ID: Provider specific resource identifier for that resource type
  * Ex: `subnet-ad536afg9`

Example:
```
# Importing a subnet into a configuration
terraform import -var-file="terraform.tfvars" \
   module.vpc.aws_subnet.public[2] subnet-ad536afg9
```