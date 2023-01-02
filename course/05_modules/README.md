# Using a module for common configurations
Modulo 8

## Potential improvements

- Leverage the VPC module for networking
- Create a module for S3 buckets
  - Include load balancer permissions
  - Include instance profile permissions

## Terraform Modules

A module really is just a collection of Terraform files in a directory

### AWS VPC Terraform module

[Module at HashiCorp](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)

**Important topics during the configuration of the module**
* `=3.10.0` to specify the module version and use strictly that version until manuall update.
* Use `slice` function for provide the list of availability zones
  * `slice(data.aws_availability_zones.available.names,0,(var.vpc_subnet_count))` with pick avaibality zones from the data source at index 0 (star index for the slice) to index of the number of subnets configured as variable (ending **non inclusive** index).

