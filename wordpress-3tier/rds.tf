#
# rds.tf
#

resource "aws_db_subnet_group" "dbsn_a" {
  name       = "dbsn_a"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "dbsn_a"
  }
}

resource "aws_security_group" "sg_mysql" {
  name   = "sg_mysql"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_mysql"
  }
}

#resource "aws_db_parameter_group" "param_a" {
#  name   = "param_a"
#  family = "mysql"
#
#  parameter {
#    name  = "log_connections"
#    value = "1"
#  }
#}

resource "aws_db_instance" "db_a" {
  identifier             = "wp-db" # The identifier of the DB in RDS
  instance_class         = "db.t4g.micro"
  allocated_storage      = 20
  engine                 = "mariadb"
  engine_version         = "11.4.5"
  username               = local.DB_USERNAME
  password               = local.DB_PASSWORD
  db_subnet_group_name   = aws_db_subnet_group.dbsn_a.name
  vpc_security_group_ids = [aws_security_group.sg_mysql.id]
  #parameter_group_name   = aws_db_parameter_group.param_a.name
  skip_final_snapshot = true
  multi_az            = false
  availability_zone   = data.aws_availability_zones.available.names[0]
  db_name             = local.DB_NAME # The name of the DB in Mariadb
}

