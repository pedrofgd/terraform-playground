# Bucket name
variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to create"
}

# ELB service account arn
variable "elb_service_account_arn" {
  type        = string
  description = "ARN of ELB service account"
}

# Common tags
variable "common_tags" {
  type        = map(string)
  description = "Common tags for label resources"
  default     = {}
}