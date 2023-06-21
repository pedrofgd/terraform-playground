# Managing State in Terraform
Modulo 4

## Overview

- State data exploration
- Backend options for state data
- Migrating state data

## Globomantics environment
*Globomantic is the fictional company use for examples in the course*

* Work with the larger team
* Create infrastructure for other teams
* Enable collaboration through remote state
* Restrict access for other teams

## Backend plan

![Backend plan](./../assets/globomantics_backend_plan.png)

The plan is to set **Consul (by HashiCorp)** as the backend:
- [ ] Add a path called `networking` in the Consul K/V store
- [ ] Add a `state` path to store all state configuration as a key on that path
- [ ] Interact with consul through local workstation
- [ ] Set up **token** and supply as part of authentication
- [ ] Apply **policies** to restrict read and write operations to our data

## Setting up Consul

We'll be running Consul **locally**

First of all, [download Consul](https://developer.hashicorp.com/consul/downloads)

Then, in the project folder, create `consul` directory and a config file at `config/consul-config.hcl`:
```
## server.hcl

ui = true
server = true
bootstrap_expect = 1
datacenter = "dc1"
data_dir = "./data"

acl = {
   enabled = true
   default_policy = "deny"
   enable_token_persistence = true
}
```

Move to `consul` directory, create a folder called `data` and run the following command to initialize `Consul`: 

`consul agent -bootstrap -config-file="config/consul-config.hcl" -bind="127.0.0.1"`

Open a new terminal window and generate the bootstrap token with command `consul acl bootstrap`, that generates something like this:
```
AccessorID:       bf0f37e2-e037-518f-eca4-c7b494926fe0
SecretID:         f9985cb0-d1ab-1eac-3b15-d6039cb54859
Description:      Bootstrap Token (Global Management)
Local:            false
Create Time:      2023-06-20 20:35:17.473044 -0300 -03
Policies:
   00000000-0000-0000-0000-000000000001 - global-management
```

Export an environment variable `CONSUL_HTTP_TOKEN` with the `SecretID` value returned by the previous command, that we will use to access Consul
   - `export CONSUL_HTTP_TOKEN="f9985cb0-d1ab-1eac-3b15-d6039cb54859"` in this example

Set up information inside Consul, **using Terraform**, so it can store our remote state with an [`main.tf`](./consul/main.tf) file.

`init`, `validate`, `plan` and `apply` this configurations to set up Consul. `main.tf` will show an output with accessor_ids for access the paths that were just created:

```
mary_token_accessor_id = "d5ba5042-7af6-daca-be4c-98d1fd27fb1c"
sally_token_accessor_id = "a0f2608e-1607-c16f-7434-4ec0ba142b48"
```

With this values, we can grab information about the credentials with the command: `consul acl token read -id ACCESSOR_ID`. For example:

```
❯ consul acl token read -id d5ba5042-7af6-daca-be4c-98d1fd27fb1c

AccessorID:       d5ba5042-7af6-daca-be4c-98d1fd27fb1c
SecretID:         d62fe76e-fc86-738d-0748-ffb8e142c6aa
Description:      token for Mary Moe
Local:            false
Create Time:      2023-06-20 20:39:41.38283 -0300 -03
Policies:
   40a17f14-d89f-bed1-5c8b-48a3c4f16cee - networking
```

and

```
❯ consul acl token read -id a0f2608e-1607-c16f-7434-4ec0ba142b48

AccessorID:       a0f2608e-1607-c16f-7434-4ec0ba142b48
SecretID:         54e9e0ec-3b68-f14a-aa39-c45f2f553df0
Description:      token for Sally Sue
Local:            false
Create Time:      2023-06-20 20:39:41.382832 -0300 -03
Policies:
   29abeafa-4ede-bf22-3f64-08a99178b5dd - applications
```

The `**SecretID**` will be important for later.

### Consul UI

Access Consul UI at [127.0.0.1:8500](http://127.0.0.1:8500/ui/dc1/services), as configured, and **LogIn** with the global `SecretID`, that we configured earlier (the first one after run Consul).

## Migrating Terraform State

Now, outside the `consul` directory, we finish the configuration of the project using Consul as our backend.

**Process overview (no need to execute yet):**
 1. Update backend configuration
 2. Run `terraform init` (re-initialize configuration)
 3. Confirm state migration (it copies all the data from local to remote)
 4. That's it

Now start executing the following commands and actions:

**Performing the migration:**
1. Add a `backend.tf` file:
```
terraform {
  backend "consul" {
    address = "127.0.0.1:8500"
    scheme = "http"
  }
}
```
1. Set the `CONSUL_HTTP_TOKEN` to Mary Moe `SecretID`
   - `export CONSUL_HTTP_TOKEN="d62fe76e-fc86-738d-0748-ffb8e142c6aa"`
2. Init terraform again and specify the path to store the state:
   - `terraform init -backend-config="path=networking/state/globo-primary"`


**Obs 1:** We don't need to specify any authentication information, because we are storing that in our environment variable

**Obs 2:** The `terraform.tfstate` will not be deleted, but it will be leave blank

**Obs 3:** this configuration is very basic. Could be using HTTPS to communicate with Consul and the Consul Server could be at a real remote location.

**Then**, access [Consul UI at K/V tab](http://127.0.0.1:8500/ui/dc1/kv). The state will be at `networking/state/globo-primary`, as configured.

![Our Terraform State now stored in Consul](../assets/tf_state_stored_in_consul.png)

