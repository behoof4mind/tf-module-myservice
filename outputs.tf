output "clb_dns_name" {
  value       = aws_elb.myservice.dns_name
  description = "The domain name of the load balancer"
}

output "db_dns_name" {
  value       = aws_db_instance.myservice-db.endpoint
  description = "RDS instance endpoint"
}