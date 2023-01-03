# Updating my configuration with more resources
Modulo 5

## Potential improvements

- Multi regions
- Multi instances

## Deployment Architecture

* VPC (Virtual Private Cloud)
  * Subnet-1 (AZ1) => EC2 instance
  * Subnet-2 (AZ2) => EC2 instance
  * Application Load Balancer (public endpoint for application, that direct traffic to our instances)

`AZ` = Availability Zone.

As subnets estão em diferentes zonas.

## Additional Data Sources and Resources

- Data source (list of Availability Zones in the current region) (semelhante ao que já foi feito para a versão do Linux na instância no [base web app](/course/01_base_web_app/main.tf))
  - `"aws_availability_zones"`


- Load balancer resources
  - `"aws_lb"`: AWS application load balancer
  - `"aws_lb_target_group"`: group that application load balancer can target when a request come in
  - `"aws_lb_listener"`: listens on port 80 to onbound requests
  - `"aws_lb_target_group_attachment"`: associate target group to EC2 instances
  - Then additional Subnet, EC2 instance and security group for de load balancer

## 

- [ ] Configurar Load Balancer para utilizar apenas HTTPS (no exemplo da documentação já está como HTTPS e com um certificado)

