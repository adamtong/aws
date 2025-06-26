#
# efs.tf
#

# EFS File system for WordPress contents
resource "aws_efs_file_system" "efs_a" {
  creation_token = "efs_a"

  tags = {
    Name = "efs_a"
  }
}

# Security group to allow inbound EFS traffic
resource "aws_security_group" "sg_efs" {
  name   = "sg_efs"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_efs"
  }
}

# Mount target for each public subnet
resource "aws_efs_mount_target" "mt_a" {
  for_each = toset(module.vpc.public_subnets)

  file_system_id  = aws_efs_file_system.efs_a.id
  subnet_id       = each.value
  security_groups = [aws_security_group.sg_efs.id]
}
