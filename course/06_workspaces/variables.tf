variable "naming_prefix" {
  type        = string
  description = "Naming prefix for resources"
  default     = "tfpg"
}

variable "aws_region" {
  type        = string
  description = "AWS region to use for resource"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  type        = map(string)
  description = "Base CIDR Block for VPC"
}

variable "vpc_subnet_count" {
  type        = map(number)
  description = "Number of subnets to create"
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "Map a public IP address for Subnet instances"
  default     = true
}

variable "instance_count" {
  type        = map(number)
  description = "Number of AWS EC2 instances to create"
}

variable "aws_instance_type" {
  type        = map(string)
  description = "Type for AWS EC2 instance"
}

variable "company" {
  type        = string
  description = "Company name for resource tagging"
  default     = "terraform-playground"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
}

variable "billing_code" {
  type        = string
  description = "Billing code for resource tagging"
}
