output "public-ip-master" {
  value = module.webserver.instance_master.public_ip
}
output "public-ip-worker-1" {
  value = module.webserver.instance_worker_1.public_ip
}
output "public-ip-worker-2" {
  value = module.webserver.instance_worker_2.public_ip
}

