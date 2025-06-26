#
# asg.tf - auto scaling group
# Ref: [Manage AWS Auto Scaling Groups](https://developer.hashicorp.com/terraform/tutorials/aws/aws-asg)
#

# Launch template for launching EC2 instances in ASG
#
resource "aws_launch_template" "lt_a" {
  name          = "lt_a"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  key_name      = var.key_name

  # Specify the security groups for the network interface 
  # instead of for the VPC
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.sg_ec2.id]
  }
  # vpc_security_group_ids  = [aws_security_group.sg_ec2.id]

  # Instance profile to grant role to EC2 instances
  iam_instance_profile {
    name = aws_iam_instance_profile.ac2_iam_profile.name
  }

  # Install and start httpd
  #user_data = filebase64("user_data.sh")
  user_data = base64encode(templatefile("user_data_wp.sh", {
    DB_NAME     = "${local.DB_NAME}",
    DB_USERNAME = "${local.DB_USERNAME}",
    DB_PASSWORD = "${local.DB_PASSWORD}",
    DB_HOST     = "${aws_db_instance.db_a.address}",
    EFS_ID      = "${aws_efs_file_system.efs_a.id}"
  }))

  # Specify unlimited cpu credits to allow more flexibility with scaling
  credit_specification {
    cpu_credits = "unlimited"
    #cpu_credits = "standard"
  }
}

# Auto scaling group of EC2 instances
#
resource "aws_autoscaling_group" "asg_a" {
  name             = "asg_a"
  min_size         = 1
  max_size         = 3
  desired_capacity = 1
  # A list of subnets for launching EC2 instances for the ASG
  vpc_zone_identifier = module.vpc.public_subnets
  # Not need to specify availability zones since they are determined by the subnets.
  #availability_zones = data.aws_availability_zones.available.names

  launch_template {
    id      = aws_launch_template.lt_a.id
    version = "$Latest"
  }
  # Do health check against the load balancer
  health_check_type = "ELB"
  #health_check_type = "EC2"
  tag {
    key                 = "Name"
    value               = "ac2_asg"
    propagate_at_launch = true
  }
}

# Scale down by one instance
#
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.asg_a.name
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "scale_down_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2 # compare statistics over 2 periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60 # evaludate statistics over periods of 1 minute
  statistic           = "Average"
  threshold           = 10

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_a.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}

# Scale up by one instance
#
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.asg_a.name
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "scale_up_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2 # compare statistics over 2 periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60 # evaluate statistics over periods of 1 minute
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_a.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}