#vpc.tf

// 키 이름
resource "ncloud_login_key" "create_key" {
  key_name = "${var.pnoun}-key"
}
resource "local_file" "ncp_pem" {
  filename = "${var.pnoun}_key.pem"
  content = ncloud_login_key.create_key.private_key
}
// VPC 생성
resource "ncloud_vpc" "create_vpc" {
    name = "${var.pnoun}-vpc-001"
    ipv4_cidr_block = var.vpc_cidr_block
}
// Subnet 생성
resource "ncloud_subnet" "create_bas_subnet" {
  vpc_no = ncloud_vpc.create_vpc.id
  subnet = cidrsubnet(ncloud_vpc.create_vpc.ipv4_cidr_block, 8, 10)
  zone = var.zone[0]
  network_acl_no = ncloud_vpc.create_vpc.default_network_acl_no
  subnet_type = "PUBLIC"
// PUBLIC(Public) | PRIVATE(Private)
  name = "${var.pnoun}-bastion-sub"
  usage_type = "GEN"
}
// Subnet 생성
resource "ncloud_subnet" "create_pub_subnet" {
    count = length(var.zone)
  vpc_no = ncloud_vpc.create_vpc.id
  subnet = cidrsubnet(ncloud_vpc.create_vpc.ipv4_cidr_block, 8, ( 20 + count.index ))
  zone = var.zone[count.index%2]
  network_acl_no = ncloud_vpc.create_vpc.default_network_acl_no
  subnet_type = "PRIVATE"
// PUBLIC(Public) | PRIVATE(Private)
  name = "${var.pnoun}-web-sub-${count.index+1}"
  usage_type = "GEN"
}
resource "ncloud_subnet" "create_pri_subnet" {
    count = length(var.zone)
  vpc_no = ncloud_vpc.create_vpc.id
  subnet = cidrsubnet(ncloud_vpc.create_vpc.ipv4_cidr_block, 8, ( 30 + count.index ))
  zone = var.zone[count.index%2]
   network_acl_no = ncloud_vpc.create_vpc.default_network_acl_no
  subnet_type = "PRIVATE"
// PUBLIC(Public) | PRIVATE(Private)
  name = "${var.pnoun}-was-sub-${count.index+1}"
  usage_type = "GEN"
}
resource "ncloud_subnet" "create_db_subnet" {
    count = length(var.zone)
  vpc_no = ncloud_vpc.create_vpc.id
  subnet = cidrsubnet(ncloud_vpc.create_vpc.ipv4_cidr_block, 8,  40 + count.index )
  zone = var.zone[count.index%2]
  network_acl_no = ncloud_vpc.create_vpc.default_network_acl_no
  subnet_type = "PRIVATE"
// PUBLIC(Public) | PRIVATE(Private)
  name = "${var.pnoun}-db-sub-${count.index+1}"
  usage_type = "GEN"
}
resource "ncloud_subnet" "create_lb_subnet" {
  vpc_no         = ncloud_vpc.create_vpc.id
  subnet         = cidrsubnet(ncloud_vpc.create_vpc.ipv4_cidr_block, 8, 50)
  zone           = var.zone[0]
  network_acl_no = ncloud_vpc.create_vpc.default_network_acl_no
  subnet_type    = "PUBLIC" // PUBLIC(Public) | PRIVATE(Private)
  // below fields is optional
  name           = "${var.pnoun}-pub-lb"
  usage_type     = "LOADB"    // GEN(General) | LOADB(For load balancer)
}
resource "ncloud_subnet" "create_lb_pri_subnet" {
  vpc_no         = ncloud_vpc.create_vpc.id
  subnet = cidrsubnet(ncloud_vpc.create_vpc.ipv4_cidr_block, 8, 60 )
  zone           = var.zone[0]
  network_acl_no = ncloud_vpc.create_vpc.default_network_acl_no
  subnet_type    = "PRIVATE" // PUBLIC(Public) | PRIVATE(Private)
  // below fields is optional
  name           = "${var.pnoun}-pri-lb"
  usage_type     = "LOADB"    // GEN(General) | LOADB(For load balancer)
}
resource "ncloud_subnet" "create_nat_subnet" {
  vpc_no         = ncloud_vpc.create_vpc.id
  subnet = cidrsubnet(ncloud_vpc.create_vpc.ipv4_cidr_block, 8, 70 )
  zone           = var.zone[0]
  network_acl_no = ncloud_vpc.create_vpc.default_network_acl_no
  subnet_type    = "PUBLIC" // PUBLIC(Public) | PRIVATE(Private)
  // below fields is optional
  name           = "${var.pnoun}-nat-sub"
  usage_type     = "NATGW"    // GEN(General) | LOADB(For load balancer)
}
resource "ncloud_nat_gateway" "create_nat_gateway" {
  vpc_no      = ncloud_vpc.create_vpc.id
  subnet_no   = ncloud_subnet.create_nat_subnet.id
  zone        = var.zone[0]
  // below fields are optional
  name        = "${var.pnoun}-nat-gw"
  description = "description"
}
resource "ncloud_route" "create_route_nat" {
  route_table_no         = ncloud_vpc.create_vpc.default_private_route_table_no
  destination_cidr_block = "0.0.0.0/0"
  target_type            = "NATGW" // NATGW (NAT Gateway) | VPCPEERING (VPC Peering) | VGW (Virtual Private Gateway).
  target_name            = ncloud_nat_gateway.create_nat_gateway.name
  target_no              = ncloud_nat_gateway.create_nat_gateway.id
}
