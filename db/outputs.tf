output "db_dns_name" {
  value       = aws_db_instance.myservice-db.endpoint
  description = "RDS instance endpoint"
}