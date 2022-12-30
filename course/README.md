# 

Curso: [Pluralsight: Terraform - Getting Started by Ned Bellavance](https://app.pluralsight.com/course-player?clipId=76c9a418-70e7-488e-b097-e4f9672f7cf7)

## Terraform

- Ferramenta para automatizar criação de infraestrutura
- Open-source e multi cloud
- Sintaxe declarativa
- HashiCorp Configuration Lanhguage (HCL) ou JSON
- Push based deployment

**Componentes**
* Executavel (arquivo binário invocado para rodar o Terraform)
* Configuration files (um ou mais `.tf`)
* Provider plugins ([Terraform Registry](https://registry.terraform.io/))
* State data (mapa do que foi configurado e do que existe "ambiente alvo")

## Instalation

```
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

Enable tab completion:
```
# se nao tiver ainda...
touch ~/.zshrc ou touch ~/.bashrc

terraform -install-autocomplete
```

[Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## HCL syntax

**Object types:**
* Providers (AWS, Azure, GCP...)
  * Define informations for a provider I want to use
* Resources (virtual machine instance, database, virtual network...)
  * What I want to create in a target environment
  * Each resource is associated with a provider
* Data sources (regions available, users...)
  * Query information from a provider
  * Gets data it may be used in configuration

**Exemplos de sintaxe:**
``` JSON
block_type "label" "name_label" {
   key = "value"
   nested_block {
      key = "value"
   }
}
```

**Object reference:**
```
<resource_type>.<name_label>.<attribute>
label.name_label.key
```

## Terraform Workflow

* `terraform init`
  * Download dos plugins utilizados nos arquivos de configuração
* `terraform validate`
  * Verifica os arquivos de configuração, sem olhar para nenhum serviço remoto, apenas os arquivos
* `terraform plan`
  * Determina as diferenças entre as configurações do ambiente e as dos arquivos de configuração para planejar a execução (opcional)
* `terraform apply`
  * Executa as alteraçãos
  * Se executado mais de uma vez, sem alterações nas configurações, não há nada para ser aplicado
* `terraform destroy`
  * Remover tudo do ambiente alvo com base no que está no State Data do Terraform

## Variables and outputs

* Input variables
* Local values (locals)
* Output values

**Variables:**
```
variable "name_label" {
  type = value
  description = "value"
  default = "value"
  sensitive = true | false (default)
}
```

Variable reference:
`var.<name_label>` => `var.aws_region`, por exemplo

**Terraform Data Types**
- Primitive => string, number, bool
- Collection => list (ordenado), set (não ordenado), map (key-value)
- Strucutural => tuple, object

* Collections são de apenas um tipo

Exemplos:
``` Python
# List
[1, 2, 3, 4]
["us-east-1", "us-east-2"]
[1, "us-east-2", true] # INVALID LIST!

# Map
{
  small = "t2.micro"
  medium = "t2.large"
  large = "t2.large"
}
```

Variable of type List:
```
variable "aws_regions" {
  type = list(string)
  description = "Region to use for AWS resources"
  default = ["us-east-1", "us-east-2", "us-west-1"]
}
```

Referencing Collection Values
```
var.<name_label>[<element_number>]
var.aws_regions[0]
var.aws_regions (lista inteira)
```

Variable of type Map:
```
variable "aws_instance_sizes" {
  type = map(string)
  description = "Region to use for AWS resources"
  default = {
    small = "t2.micro"
    medium = "t2.large"
    large = "t2.large"
  }
}
```

Referencing Map Values
```
var.<name_label>.key_name ou var.<name_label>["key_name"]
var.aws_instance_sizes.small or var.aws_instance_sizes["small"]
```

[Exemplo em base_web_app/variables.tf](/course/base_web_app/variables.tf)

### Local values

```
locals {
  key = "value"
}
```

Locals reference:
```
local.<name_label> # on singular...
```

[Exemplo em base_web_app/locals.tf](/course/base_web_app/locals.tf)

### Output values

"How to get information out of terraform. 
Printed out to the terminal window at the end of configuration run."

Sintaxe:
```
output "name_label" {
  value = output_value
  description = "Description of output"
  sensitive = true | false
}
```

## Supply Variable Values

* `default` value (no arquivo variables)
* `-var` flag
```
terraform apply -var="image_id=ami-abc123"
terraform apply -var='image_id_list=["ami-abc123","ami-def456"]' -var="instance_type=t2.micro"
terraform apply -var='image_id_map={"us-east-1":"ami-abc123","us-east-2":"ami-def456"}'
```
* `-var-file` flag
```
terraform apply -var-file="testing.tfvars"
```
* `terraform.tfvars` ou `terraform.tfvars.json`
* `.auto.tfvars` ou `.auto.tfvars.json` no mesmo diretório
* Environment variable `TF_VAR_<variable_name>`

**Ordem (evalutaion precedence):**
1. `TF_VAR_`
2. `.tfvars` ou .json
3. `.auto.tfvars` ou .json
4. `-var-flie` flag
5. `-var` flag
6. **command line prompt**

