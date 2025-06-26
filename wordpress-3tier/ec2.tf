#
# ec2.tf 
#

# Security group to allow inbound SSH and HTTP traffic to WordPress
#
resource "aws_security_group" "sg_ec2" {
  name        = "sg_ec2"
  description = "Allow inbound SSH and HTTP traffic to WordPress"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
    Name = "sg_ec2"
  }
}

# Role to attach policies that give EC2 instances access to SSM,
# ColudWatch and KMS
#
resource "aws_iam_role" "ac2_iam_role" {
  name = "ac2_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}


# Attach multiple policies to the role using for_each
#
resource "aws_iam_role_policy_attachment" "ac2_policy_attachments" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",               # For SSM
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",       # For CloudWatchAgent
    "arn:aws:iam::aws:policy/service-role/ROSAKMSProviderPolicy" # For KMS
  ])
  role       = aws_iam_role.ac2_iam_role.name
  policy_arn = each.value
}


# IAM profile for the EC2 instances
#
resource "aws_iam_instance_profile" "ac2_iam_profile" {
  name = "ac2_iam_profile"
  role = aws_iam_role.ac2_iam_role.name
}

# A standalone EC2 instance for WordPress
#
#resource "aws_instance" "wp_a" {
#  ami = data.aws_ami.amazon_linux.id
#  instance_type               = "t3.micro"
#  key_name                    = var.key_name
#  vpc_security_group_ids      = [aws_security_group.sg_ec2.id]
#  subnet_id                   = module.vpc.public_subnets[0]
#  iam_instance_profile        = aws_iam_instance_profile.ac2_iam_profile.name
#  associate_public_ip_address = true
#  user_data_base64 = base64encode(templatefile("user_data_wp.sh", {
#    DB_NAME     = "${local.DB_NAME}",
#    DB_USERNAME = "${local.DB_USERNAME}",
#    DB_PASSWORD = "${local.DB_PASSWORD}",
#    DB_HOST     = "${aws_db_instance.db_a.address}",
#    EFS_ID      = "${aws_efs_file_system.efs_a.id}"
#  }))
#
#  credit_specification {
#    cpu_credits = "standard"
#  }
#
#  tags = {
#    Name = "wp_a"
#  }
#}
