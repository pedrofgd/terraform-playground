variable "aws_access_key" {
  type        = string
  description = "AWS access key"
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
  sensitive   = true
}

variable "aws_region" {
  type        = string
  description = "AWS region to use for resource"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  type         = string
  description  = "Base CIDR Block for VPC"
  default      = "10.0.0.0/16"
}

variable "vpc_subnets_cidr_block" {
  type         = list(string)
  description  = "CIDR Blocks for subnets in VPC"
  default      = [ "10.0.0.0/24", "10.0.1.0/24" ]
}

variable "map_public_ip_on_launch" {
  type = bool
  description = "Map a public IP address for Subnet instances"
  default = true
}

variable "aws_instance_type" {
  type = string
  description = "Type for AWS EC2 instance"
  default = "t2.micro"
}

variable "company" {
  type = string
  description = "Company name for resource tagging"
  default = "terraform-playground"
}

variable "project" {
  type = string
  description = "Project name for resource tagging"
}

variable "billing_code" {
  type = string
  description = "Billing code for resource tagging"
}
