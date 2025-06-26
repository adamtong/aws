#
# outputs.tf
#

#output "public_subnets" {
#  value = module.vpc.public_subnets
#}
#
#output "private_subnets" {
#  value = module.vpc.private_subnets
#}

output "db_endpoint" {
  value = aws_db_instance.db_a.endpoint
}

output "db_host" {
  value = aws_db_instance.db_a.address
}

output "db_username" {
  value     = aws_db_instance.db_a.username
  sensitive = true
}

output "efs_id" {
  value = aws_efs_file_system.efs_a.id
}

output "efs_name" {
  value = aws_efs_file_system.efs_a.dns_name
}

output "asg_name" {
  value = aws_autoscaling_group.asg_a.name
}

output "asg_arn" {
  value = aws_autoscaling_group.asg_a.arn
}

output "lb_name" {
  value = aws_lb.lb_a.dns_name
}

output "lb_arn" {
  value = aws_lb.lb_a.arn
}
