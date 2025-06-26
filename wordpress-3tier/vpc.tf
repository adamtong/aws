#
# vpc.tf
# Ref: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/6.0.1
#
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = "vpc_a"
  cidr = "10.0.0.0/16"
  azs  = data.aws_availability_zones.available.names

  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_names  = ["sn_app_a", "sn_app_b", "sn_app_c"]
  private_subnets      = ["10.0.31.0/24", "10.0.32.0/24", "10.0.33.0/24"]
  private_subnet_names = ["sn_db_a", "sn_db_b", "sn_db_c"]

  enable_dns_hostnames = true
  enable_dns_support   = true
}

