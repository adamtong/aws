# Create a 3-tier WordPress application

Features:
* VPC, public and private subnets created with the [AWS VPC Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/)
* Free-Tier RDS/MariaDB DB instance in the private subnets
* EFS file system for hosting WordPress contents
* ASG for running WordPress in the public subnets
* Autoscaling policies to scale up and down the number of instances based on the CPUtilization.
* Load Balancer to direct HTTP requests to the ASG.

The infrastructure needs to be created in a two-steps:
```bash
terraform apply -target="module.vpc" -auto-approve
terraform apply -auto-approve
```
