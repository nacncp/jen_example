#output.tf
output "server_public_ip" {
  value       = ncloud_public_ip.public-ip.*.public_ip
  description = "The public IP of the Instance"
}
output "loadbalancer_public_dns" {
  value       = ncloud_lb.create_lb.*.domain
  description = "The lb DNS of the Instance"
}
