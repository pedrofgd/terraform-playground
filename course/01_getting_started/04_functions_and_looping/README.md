# Using Functions and Looping in your configuration
Modulo 7

## Potential improvements

- Dynamically increase instances
- Use a template for startup script
- Simplify networking input
- Add consistent name prefix

## Deployment architecture

These improvements aren't going to change our architecture.

The goal is to keep the deployment the same while improving our infrastructure as code.

## Wich resources are repeating

- [x] EC2 instances
- [x] Load balancer group attachment
- [x] Subnets
- [x] Route table association
- [x] Security groups per instance
- [x] S3 object (per file)

## Functions to use

**Template for startup script:**
* `templatefile(file_location, { map of variables })`: reads the content of a file and replace variables based on received map

**Simplify networking input determining the subnet addresing dinamically:**
* `cidrsubnet(cidr_range, subnet bits to add, network number)`
  * example of use: `cidrsubnet(var.vpc_cidr_block, 8, 0)`, that will return a set of subnetworks
    * var.vpc_cidr_block is set to 10.0.0.0/16
    * 8 is the number of bits to add to make a /24
    * 0 means that the function will select the first available network from the set of subnetworks

**Consistent name prefix:**
* `merge(common_tags, { map of additional tags })`
* `lower("bucket name")`

## Important tip on creating instances on subnets

Solution: `subnet_id = aws_subnet.subnets[count.index % 2].id`

**Problem:** 

The previous configurtion works well with we are creating the same number of instances and subnets.

If we would have 4 instances, it would end it up like this:
* Instance 0 -> subnet 0
* Instance 1 -> subnet 1
* Instance 2 -> subnet 2
* Instance 3 -> subnet 3

**But**, if it was needed to create 4 instances across 2 subnets we would have an error, since `aws_subnets.subnets[count.index]` would try to count to 4, but would have just 2 subnet resources available.

**Solution explanation:**

The module `%` operator is helpulf in that case. Having 2 subnet instances, we can calculate the index of the instance module the total of subnets available. Using it, we would have the following:
* Instance 0 -> subnet 0, since 0 % 2 = 0
* Instance 1 -> subnet 1, since 1 % 2 = 1
* Instance 2 -> subnet 0, since 2 % 2 = 0
* instance 3 -> subnet 1, since 3 % 2 = 1





