#
# data.tf
#

# The set of all available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# AMI for the latest revision of Amazon Linux 2023
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # Amazon
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64*"]
    # We need the second 2023 in the file pattern to avoid picking the minimal version of Amazon Linux
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Name of the WordPress database
data "aws_ssm_parameter" "database_name" {
  name = "/app/wordpress/database_name"
}

# Username of the WordPress user
data "aws_ssm_parameter" "database_username" {
  name = "/app/wordpress/database_username"
}

# Password of the WordPress user
data "aws_ssm_parameter" "database_password" {
  name            = "/app/wordpress/database_password"
  with_decryption = true
}

# The root user password of the MySQL database.
# This is only used when the database is implemented directly in MySQL
# and not on top of RDS.
data "aws_ssm_parameter" "database_root_password" {
  name            = "/app/wordpress/database_root_password"
  with_decryption = true
}
