output "instance_master" {
  value = aws_instance.k8-master
}
output "instance_worker_1" {
  value = aws_instance.k8-worker_1
}
output "instance_worker_2" {
  value = aws_instance.k8-worker_2
}