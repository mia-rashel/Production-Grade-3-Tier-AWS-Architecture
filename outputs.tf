output "alb_dns_name" {
  description = "DNS name of the Load Balancer"
  value       = module.loadbalancer.alb_dns_name
}

output "db_endpoint" {
  description = "RDS endpoint"
  value       = module.database.db_endpoint
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.compute.asg_name
}