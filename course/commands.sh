## Add credentials as environment variables
# For Linux and MacOS
export TF_VAR_aws_access_key=YOUR_ACCESS_KEY
export TF_VAR_aws_secret_key=YOUR_SECRET_KEY

# For PowerShell
$env:TF_VAR_aws_access_key=YOUR_ACCESS_KEY
$env:TF_VAR_aws_secret_key=YOUR_SECRET_KEY

## Add credentials as environment variables in AWS provider format
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"