# Working with existing resources
Modulo 3

## Initial infrastructure

* VPC (Virtual Private Cloud)
  * 2 public subnets (distributed between `us-east-1a` and `us-eat-1b` az)
  * 2 private subnets (distributed between `us-east-1a` and `us-eat-1b` az)

## Improvement needed

> Add a public and private subnet to the us-east-1c availability zone

Jimmy (the Junior admin) created the subnets using a [script](./junior_admin.sh) and not Terraform.

:warning: **Important:** I updated the `.sh` script at line 5 from original`sudo apt install jq -y` to `brew install jq`

**Now we need to have those subbnets under management of Terraform.** The way we are going to do that is by using the `import` command.

## Importing Jimmy resources

1. Modify [`terraform.tfvars`](./terraform.tfvars) to include the CIDR of 3rd subnet in public/private existing variables and update `subnet_count`
   * Para esse caso, só modificar o arquivo de configurações já é suficiente, mas a primeira etapa, de modo geral, é atualizar as configurações para incluir todos os recursos que devem ser importados
2. Run a `terraform plan -out m3.tfplan` in order to get the `ADDR` of the resources we are about to add
3. Run terraform import for each address to be added and include the `ID` of the resource previously created by Jimmy (`.sh` script)
```
terraform import --var-file="terraform.tfvars" "module.vpc.aws_route_table.private[2]" "rtb-0e52df473a928cadc"
terraform import --var-file="terraform.tfvars" "module.vpc.aws_route_table_association.private[2]" "subnet-012e01075e85f23c5/rtb-0e52df473a928cadc"
terraform import --var-file="terraform.tfvars" "module.vpc.aws_subnet.private[2]" "subnet-012e01075e85f23c5"
terraform import --var-file="terraform.tfvars" "module.vpc.aws_route_table_association.public[2]" "subnet-07c238ac12fd7ebd9/rtb-037f01e80ce511510"
terraform import --var-file="terraform.tfvars" "module.vpc.aws_subnet.public[2]" "subnet-07c238ac12fd7ebd9"
```

:eight_pointed_black_star: I made something wrong while running the `.sh` script, then needed to remove some resources I imported from the state. To do it so I used:
1. `terraform state list`
2. `terraform state rm "<resource_name>"`
