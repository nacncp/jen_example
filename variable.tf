#variable.tf
// VPC 이름
variable "pnoun" {
  type    = string
  default = "molru"
}
// VPC 생성
variable "vpc_cidr_block" {
  type    = string
  default = "10.101.0.0/16"
}
// Subnet을 생성할 Zone 선택(ex:KR-1,KR-2...)
variable "zone" {
  type    = list(any)
  default = ["KR-2", "KR-1"]
}
/*
// Server_bas_ip 사용 대역
variable "server_bas_CIDR" {
  type = list
  default= ["10.0.01.6"]
}
// Server_pub_ip 사용 대역
variable "server_pub_CIDR" {
  type = list
  default= ["10.0.21.6", "10.0.22.7"]
}
// Server_pri_ip 사용 대역
variable "server_pri_CIDR" {
   count     = length(var.subnet_pri_CIDR)
  type = list
 default= ["10.101.30+${count.index}.${count.index}"]
}
// Server_db_ip 사용 대역
variable "server_db_CIDR" {
  type = list
  default= ["10.0.41.6", "10.0.42.7"]
}
// Server_lb_ip 사용 대역
variable "server_lb_CIDR" {
  type = list
  default= ["10.0.41.6", "10.0.42.6" ]
}
// Server_lb_ip 사용 대역
variable "server_lb_CIDR" {
  type = list
  default= ["10.0.41.6", "10.0.42.6" ]
}
*/
// NATGW 여부
variable "natgw_chk" {
  type    = bool
  default = false
}
// Route table ID
variable "route_table_no" {
  type    = string
  default = ""
}
// delet
variable "client_ip" {
  type    = string
  default = "223.130.140.198"
}
