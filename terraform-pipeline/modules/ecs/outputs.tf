output "cluster" {
  value = aws_ecs_cluster.cluster
}
output "task" {
  value = aws_ecs_task_definition.task
}
output "service" {
  value = aws_ecs_service.service
}