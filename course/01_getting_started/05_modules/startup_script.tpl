#! /bin/bash
# .tpl extension is for template file, but optional
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
aws s3 cp s3://${s3_bucket_name}/website/index.html /home/ec2-user/index.html
aws s3 cp s3://${s3_bucket_name}/website/Terraform_logo.png /home/ec2-user/Terraform_logo.png
sudo rm /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/Terraform_logo.png /usr/share/nginx/html/Terraform_logo.png