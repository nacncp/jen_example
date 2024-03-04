variable "control_ip" {
  type    = string
  default = "14.32.251.203"
}

#acg pub 변수
locals {
  create_acg_rules_pub_inbound = [
    ["TCP", "${var.vpc_cidr_block}", "80"],
    ["TCP", "${var.vpc_cidr_block}", "22"],
    ["TCP", "${var.client_ip}/32", "22"],
    ["TCP", "${var.control_ip}/32", "22"],
    ["TCP", "175.45.201.195/32", "22"]
  ]

  create_acg_rules_pub_outbound = [
  ]
}
#acg pri 변수
locals {
  create_acg_rules_pri_inbound = [
    ["TCP", "${var.vpc_cidr_block}", "8080"],
    ["TCP", "${var.vpc_cidr_block}", "80"],
    ["TCP", "${var.vpc_cidr_block}", "3306"]
  ]
  create_acg_rules_pri_outbound = [
  ]
  depends_on = [ncloud_mysql.create_mysql]
}
#acg common 변수
locals {
  create_acg_rules_com_inbound = [
    ["TCP", "${var.vpc_cidr_block}", "22"]
  ]

  create_acg_rules_com_outbound = [
    ["TCP", "0.0.0.0/0", "1-65535"],
    ["UDP", "0.0.0.0/0", "1-65534"],
    ["ICMP", "0.0.0.0/0", null]
  ]
}


# acg pub
resource "ncloud_access_control_group" "create_acg_pub" {
  name        = "${var.pnoun}-acg-pub"
  description = "${var.pnoun}-acg-pub"
  vpc_no      = ncloud_vpc.create_vpc.id
}
resource "ncloud_access_control_group_rule" "create_acg_pub_role" {
  access_control_group_no = ncloud_access_control_group.create_acg_pub.id
  dynamic "inbound" { #dynamic 함수
    for_each = local.create_acg_rules_pub_inbound
    content {
      protocol   = inbound.value[0]
      ip_block   = inbound.value[1]
      port_range = inbound.value[2]
    }
  }
  dynamic "outbound" {
    for_each = local.create_acg_rules_pub_outbound
    content {
      protocol   = outbound.value[0]
      ip_block   = outbound.value[1]
      port_range = outbound.value[2]
    }
  }
}

# acg pri
resource "ncloud_access_control_group" "create_acg_pri" {
  name        = "${var.pnoun}-acg-pri"
  description = "${var.pnoun}-acg-pri"
  vpc_no      = ncloud_vpc.create_vpc.id
}
resource "ncloud_access_control_group_rule" "create_acg_pri_role" {
  access_control_group_no = ncloud_access_control_group.create_acg_pri.id
  dynamic "inbound" {
    for_each = local.create_acg_rules_pri_inbound
    content {
      protocol   = inbound.value[0]
      ip_block   = inbound.value[1]
      port_range = inbound.value[2]
    }
  }

  dynamic "outbound" {
    for_each = local.create_acg_rules_pri_outbound
    content {
      protocol   = outbound.value[0]
      ip_block   = outbound.value[1]
      port_range = outbound.value[2]
    }
  }
}
# acg pri
resource "ncloud_access_control_group" "create_acg_com" {
  name        = "${var.pnoun}-acg-com"
  description = "${var.pnoun}-acg-com"
  vpc_no      = ncloud_vpc.create_vpc.id
}
resource "ncloud_access_control_group_rule" "create_acg_com_role" {
  access_control_group_no = ncloud_access_control_group.create_acg_com.id
  dynamic "inbound" {
    for_each = local.create_acg_rules_com_inbound
    content {
      protocol   = inbound.value[0]
      ip_block   = inbound.value[1]
      port_range = inbound.value[2]
    }
  }

  dynamic "outbound" {
    for_each = local.create_acg_rules_com_outbound
    content {
      protocol   = outbound.value[0]
      ip_block   = outbound.value[1]
      port_range = outbound.value[2]
    }
  }
}

