#output.tf
output "server_public_ip" {
  value       = ncloud_public_ip.public-ip.*.public_ip
  description = "The public IP of the Instance"
}
output "loadbalancer_public_dns" {
  value       = ncloud_lb.create_lb.*.domain
  description = "The lb DNS of the Instance"
}

output "loadbalancer_subnet_cidr" {
 value = ncloud_mysql.create_mysql.mysql_server_list[0].private_domain

description = "The mysql DNS of the Instance"
}
