##########################################
# MODULES
##########################################

module "web_app_s3" {
  source = "./modules/web-app-s3"

  bucket_name             = local.s3_bucket_name
  elb_service_account_arn = data.aws_elb_service_account.root.arn
  common_tags             = local.common_tags
}

##########################################
# RESOURCES
##########################################

## aws_s3_bucket_object
resource "aws_s3_bucket_object" "website_content" {
  for_each = {
    website = "/website/index.html"
    logo    = "/website/Terraform_logo.png"
  }
  bucket = module.web_app_s3.web_bucket.id
  key    = each.value       # destination on S3 bucket
  source = ".${each.value}" # where to get that object from

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}"
  })
}