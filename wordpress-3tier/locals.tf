#
# locals.tf
#

# Create local variables for DB_NAME, DB_USERNAME, DB_PASSWORD and DB_ROOT_PASSWORD
# so that we can switch between storing them in the SSM Parameter Store
# or hard-coding them locally.
locals {
  DB_NAME = data.aws_ssm_parameter.database_name.value
}

locals {
  DB_USERNAME = data.aws_ssm_parameter.database_username.value
}

locals {
  DB_PASSWORD = data.aws_ssm_parameter.database_password.value
}

locals {
  DB_ROOT_PASSWORD = data.aws_ssm_parameter.database_root_password.value
}

