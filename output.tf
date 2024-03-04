#output.tf
output "server_public_ip" {
  value       = ncloud_public_ip.public-ip.*.public_ip
  description = "The public IP of the Instance"
}
output "loadbalancer_public_dns" {
  value       = ncloud_lb.create_lb.*.domain
  description = "The lb DNS of the Instance"
}

output "loadbalancer_private_pub" {
  value       = [for server in ncloud_server.create_pub_sv : server.network_interface[0].private_ip]
  description = "The WEB of the Private_ip"
}
