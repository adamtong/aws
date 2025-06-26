#
# lb.tf
#

# Load balancer
resource "aws_lb" "lb_a" {
  name               = "lb-a"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_lb.id]
  subnets            = module.vpc.public_subnets

  #access_logs {
  #  bucket  = aws_s3_bucket.lb_logs.id
  #  prefix  = "lb_a"
  #  enabled = false
  #}
}

# Target group for the load balancer
resource "aws_lb_target_group" "lbtg_a" {
  name     = "lbtg-a"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  #health_check {
  #  protocol = "HTTP"
  #  port = "traffic-port"
  #  path = "/"
  #}
}

# Listener for the Load balancer
resource "aws_lb_listener" "lb_lsnr_a" {
  load_balancer_arn = aws_lb.lb_a.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lbtg_a.arn
  }
}

# Attach the load balancer to the auto scaling group
# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asa_a" {
  autoscaling_group_name = aws_autoscaling_group.asg_a.id
  lb_target_group_arn    = aws_lb_target_group.lbtg_a.arn
}

# Security group for inbound traffic to load balancer
resource "aws_security_group" "sg_lb" {
  name   = "sg_lb"
  vpc_id = module.vpc.vpc_id

  ingress {
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
    Name = "sg_lb"
  }
}

# Security group for traffic from load balancer to its target group
resource "aws_security_group" "sg_lbtg" {
  name   = "sg_lbtg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
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
    Name = "sg_lbtg"
  }
}
