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
```
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

## Terraform State

- `terraform state list`: list all state resources
- `terraform state show ADDRESS`: show a speciefic resource
- `terraform state mv SOURCE ADDRESS`: move an item in state
- `terraform state rm ADDRESS`: remove an item in state

**1st rule of Terraform:** make all changes with Terraform.

**Obs:** terraform.tfstate guarda as informações de estado **inclusive os outputs** da última execução.

## Terraform Providers

* Public and private registries
* `Official`, `Verified` and `Community`
* Providers are collections of resources and data sources
* Semantic version numberered

Terraform block syntax:
```
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version "~>3.0"
    }
  }
}
```

Provider block syntax:
```
provider "provider_name" {
  alias = "alias_name"
  # Provider specific arguments
}
```

**Obs:** `alias` permite criar múltiplas instâncias de um provider. Um recurso pode usar uma instância específica com o argumento `provider`. **Ambos são opcionais**

Exemplo:
```
provider "aws" {
  alias = "west"
  # Provider specific arguments
}

resource "aws_instance" "web_server" {
  provider = aws.west
  # Resource specific arguments
}
```

Se o argumento `provider` não for especificado no recurso, o Terraform vai usar o provedor padrão, sem alias.

### Provider version

`~>` pode ser usado para pegar a versão mais atualizada de uma major version específica. Por exemplo:
* `~>3.0` pega a versão 3.x (minor version mais atualizada)
* `~>3.1` pega a versão 3.1.x (x é a versão mais atualizada)

## Terraform Planning

Order in wich to create, update or delete objects.

- Dependency graph based on what is defined in the code
- List of additions, updates and deletions
- Parallel execution

How Terraform defines order in wich changes need to happen? **References**.

Example:

![Terraform mapping dependencies example](/course/assets/tf_determining_dependencies_module_6_video_9.png)

"Sometimes a dependency is non obvious, and we need to explicity tell Terraform about it"

Example (that happens at `/03_s3_with_website`):

![Terraform dependency that exists while creating EC2 instance with IAM instance profile](/course/assets/tf_aws_iam_dependency_module_6_video_9.png)

The solution: `depends_on` argument (mas na maioria dos casos, o Terraform consegue gerenciar isso de forma automática)

## Post Deployment Configuration

Such as:
* Loading an application on to a virtual machine
* Configuring a database cluster
* Generating files on a NFS share, based on resources that are created

Can be achivied with 
* `Providers` and `Resources` depending on what it is. For example, to manage files, there's the `file` resource. For configure a MySql database, there's a MySql provider.
* Pass data on server startup, such as the `user_data` argument that we are already using for AWS EC2 instances ([example](/course/02_lb_web_app/instances.tf))
  * But the downtrack to passing script is that Terraform has no way to track if it run successfully.
* Config manager (outside Terraform), such as Ansible, Chef and Puppet.
* Terraform provisioners

### Terraform Provisioners

:warning: Provioners are "usually a bad idea", since HashiCorp considers as a **Last Resource**, after all options have been considered and found lacking.

- Part of a resource
- Executed during resource creation or destruction
- A single resource can have multiple provisioners, that will execute in the order they appear in the configuration
- There is a special resource call `null_resource`, in case that a provisioner needs to run without creating anything
- If provisioners fails, Terraform can fail the entire resource action or continue marrily (*"alegremente" segundo o tradutor*)

This options give us the lack of no beeing tracked by Terraform, so error checking, idempotence and consistency needs to be manage in another way.

**Provisioner types:**
* File: create files and directories in a remote system
```
provisioner "file" {
  connection {    # how provisioner can connect to the machine 
                   # to copy these files
    type = "ssh | winRM"
    user = "root"
    private_key = var.private_key
    host = self.public_ip   # self attribute to refer to arguments
                             # of the resource provisioner lives in
  }

  source = "/local/path/to/file.txt"
  destination = "/path/to/file.txt"
}
```

* Local-exec: allows to run script on the local machine that is executing the Terraform run
```
provisioner "local_exec" {
  command = "local command here"  # such Bash, PowerShell, Perl
}
```

* Remote-exec: allows to run a script in a remote system (can be easily replaced with startup script through something like `user_data`)
```
provisioner "remote_exec" {
  # Uses configuration information defined in the resource

  scripts = ["scripts", "to", "run"] # inline script, file, or list
}
```

## Formatting

`terraform fmt` formats files for standard patterns

## Loops in Terraform

* Count
  * Create multiple instances of a resource when the instances are very simular in nature
  * Receives an integer (including 0, for create with condition, for example)
* For_each
  * Takes a set or a map as a value
  * Is use instead of count in cases that each instance will be significantly different than the others (gives a lot more flexibility than a simple count integer)
* Dynamic blocks
  * Create multiple instances of a nested block inside a parent object
  * Advanced topic (**not** covered in the getting started course)

### Count syntax

```
resource "aws_instance" "web_server" {
  count = 3
  tags = {
    Name = "web-server-${count.index}"
  }
}
```

When `count` meta argument is used, a new special variable is available: `count.index`, that resolves for the current iteration of the loop
  * It can be used anywhere in the resource configuration block
  * Count **starts at 0**

The above example would create 3 instances of AWS EC2 instances:
  * web-server-0
  * web-server-1
  * web-server-2

**Count references:**

`<resource_type>.<name_label>[element].<attribute>`

`aws_instance.web_server[0].name` for Single instance

`aws_instance.web_server[*].name` for List of all instances

### For_each syntax

```
resource "aws_s3_object_bucket" "taco_toppings" {
  for_each = {
    cheese = "cheese.png"
    lettuce = "lettuce.png"
  }
  key = each.key      # cheese and lettuce
  value = each.value  # cheese.png and lettuce.png in case of map
}
```

The above example would create 2 S3 bucket objects.

**Obs:** If `for_each` is iterating over a set instead of a map, `each.key = each.value`

**For_each references:**

`<resource_type>.<name_label>[key].<attribute>`

`aws_s3_bucket_object.taco_toppings["cheese"].id` for Single instance

`aws_s3_bucket_object.taco_toppings[*].id` for List of all instances

## Functions and Expressions

### Terraform Expressions

We already used some Terraform Expressions: the **interpolation**, to include resource and variable values in string and the **herodoc**, to pass an entire stirng to an argument like `user_date`.

* Arithmetic and logical operators
* Conditional expresions
* For expression

### Terraform Functions

* Are built into Terraform binaries
* Func_name(arg1, agr2, arg3, ...)

**Common categories and examples:**
* Numeric (`min(42, 13, 7)`)
* String (`lower("TACOS")`)
* Collection (`merge(map1, map2)`)
* IP network (`cidrsubnet`)
* Filesystem (`file(path)`)
* Type conversion: (`toset()`)

Examples:
```
min(42,5,16)
lower("TACOCAT")
cidrsubnet(var.vpc_cidr_block, 8, 0)
cidrhost(cidrsubnet(var.vpc_cidr_block, 8, 0),5)
lookup(local.common_tags, "company", "Unknown")
lookup(local.common_tags, "missing", "Unknown")
local.common_tags
```

### Terraform console

`terraform console` starts a interactive environment where we can test different functions with real data from state

## Terraform Modules

Configuration that defines inputs, resources and outputs, that can be use for **code reuse**.

**The set of `.tf` and `.json` files in a directory is a module**. The main configuration is know as **root modules**, that can invoke other modules to create resources.

For example, the root module could invoke a lb module for create a load balancer resource. As well, the lb module could invoke both a vpc and ec2 modules:
![Terraform Modules](/course/assets/tf_modules_module_8_video_2.png)

* Modules can be used from remote or local source
  * The most common remote repository for modules is [HashiCorp](https://registry.terraform.io/browse/modules)
  * `Terraform init` if is not already in the same directory
* Versioning (same way that providers are)

### Module structure

The only way to a parent module pass information to a child module is through input variables. The child module **has no access** to local values, resource attributes and input variables of the parent module. As well, the parent model has no access to information in the child module. The only way to do that is through **output values**, so we can pass a complex objet, an entire resource or a simple string

### Module syntax

For invoke a module:
```
module "name_label" {
  source = "where to get the module from"
  version = "version_expresion"
  providers = {
    module_provider = parent_provider
  }

  # Input variable values...
}
```

Example:
```
module "taco_bucket" {
  source = "./s3" # Local source (doesn't support version)

  # Input variable values...
  bucket_name = "mah_bucket"
}
```

**Module references:**

`module.<module_name>.<output_name>`

`module.taco_bucket.bucket_id`

## For expression

As exists in any programing language, Terraform have a `for` expression for iterate through a list or map.

For expressions are a way to create a new collection based off of another collection object.

* The **input** in a for expression can be collection data type (list, set, tuple, map or object)
* The **result** of for expression will be either a tuple or an object data type

**Obs:** these are structural data types, **wich means the values inside don't all have to be of the same data type**.

* Its possible to use a filter on any value from the inputs with if statemant

:eight_pointed_black_star: the expression can starts with either curly braces or square brackets. The brackets or braces **will determine the response type**:
* Square brackets `[]` indicates that the result will be a **tuple**
* Curly braces `{}` indicates that the result will be a **object**

### Create a tuple

`[ for item in items : tuple_element ]`
- `[` specify that the expression will return a tuple
- `for` keyword indicates the for statemant
- `item` is the iterator term
- `items` is the input the expression will iterate
- `:` signals the start of the value that will be stored in each tuple element in the result collection

**Example:**

```
locals {
  toppings = ["cheese", "lettuce", "salsa"]
}

[for t in local.toppings : "Globo ${t}"]

# returns
["Globo cheese", "Globo lettuce", "Globo salsa"]
```

It is also possible to use the `range` function to iterate with a integer value. The return is a list of integers:
```
❯ terraform console
> range(5)
tolist([
  0,
  1,
  2,
  3,
  4,
])
```

It can receive as argument the start and end index or a single argument, that will count from zero to argument value.

The following example was used for get `public_subnets` while configuring AWS VPC module at [/course/05_modules/network.tf line 21](/course/05_modules/network.tf)

`[for subnet in range(var.vpc_subnet_count) : cidrsubnet(var.vpc_cidr_block, 8, subnet)]`

### Create an object

`{ for key, value in map : obj_key => obj_value }`
- `{` specify that the expression will return an object
- `key, value` from the object input
- `map` is the input the expression will iterate
- `:` signals the start of the value that will be stored in each tuple element in the result collection
- `obj_key` is the key of the object that will be stored in the result collection
- `obj_value` is the value of the object with `obj_key` that will be store in the result collection

**Example:**

```
locals {
  prices = {
    taco = "5.99"
    burrito = "9.99"
    enchilada = "7.99"
  }
}

{ for i, p in local.prices : i => ceil(p) }

# Returns
{ taco = "6", burrito = "10", enchilada = "8" }
```



