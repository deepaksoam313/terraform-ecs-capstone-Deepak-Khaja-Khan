output "alb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = aws_lb.app_alb.dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_desired_tasks" {
  description = "Number of ECS tasks desired (configured in service)"
  value       = aws_ecs_service.app.desired_count
}
