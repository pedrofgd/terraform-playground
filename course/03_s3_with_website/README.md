#
Módulo 6

## Potential improvements

- Copy website content (dynamically uploaded to the webservers at startup)
- Log traffic to an S3 bucket
- Use speciefic provider versions
- Properly format files

## Deployment Architecture

* VPC (Virtual Private Cloud)
  * S3 bucket
    * Stores website code content
    * Stores logs from **Application Load Balancer**
  * Subnet1 (AZ1)
    * EC2 instance with profile for copy content from S3 bucket
  * Subnet2 (AZ2)
    * EC2 instance with profile for copy content from S3 bucket
  * Application Load balancer (that logs traffic to S3 bucket)

**Obs:** S3 bucket need to have globally unique names
   * `Random` provider for Terraform

## Improvement dealing with Terraform Providers

- Use specific version of AWS provider (following docs)
- Authenticate with AWS using provider specific environment variables (following [Authentication and Configuration docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)) (instead of using Terraform Input Variables, for reduce risk of leaving credentials as plain text in code)
```
provider "aws" {}
```
```
$ export AWS_ACCESS_KEY_ID="anaccesskey"
$ export AWS_SECRET_ACCESS_KEY="asecretkey"
$ export AWS_REGION="us-west-2"
$ terraform plan
```

## S3 and IAM resources

- S3 resources:
  - `"aws_s3_bucket"`: S3 bucket itself
  - `"aws_s3_bucket_object"`: object in the bucket
- IAM resources:
  - `aws_iam_role`: role for instances
  - `"aws_iam_role_policy"`: role policy for S3 access
  - `aws_iam_instance_profile`: assign the role to the EC2 instances
- Data sources:
  - `"aws_elb_service_account"`: for load balances access

We want that our EC2 instances access the S3 bucket for get the website content, but we don't want the bucket to be public. That's why we use the IAM (Identity and Access Manager)


