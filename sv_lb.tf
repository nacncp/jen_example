data "ncloud_server_image" "server_image" {
  filter {
    name   = "os_information"
    values = ["Rocky Linux 8.8"]
  }
}
/*
data "ncloud_server_product" "product" {
  server_image_product_code = data.ncloud_server_image.server_image.id

  filter {
    name   = "product_code"
    values = ["SSD"]
 regex  = true
}

  filter {
    name   = "cpu_count"
    values = ["2"]
  }

  filter {
    name   = "memory_size"
    values = ["8GB"]
  }
    filter {
    name   = "base_block_storage_size"
    values = ["50GB"]
  }

  filter {
    name   = "product_type"
    values = ["HICPU"]
  }
}
*/
#web 이니스크립트
resource "ncloud_init_script" "create_web_init" {
  name = "${var.pnoun}-webcon"
  content = templatefile("${path.module}/apache.tpl", {
    domain = "${data.ncloud_lb.data_pri_lb.domain}"
  })
  depends_on = [ncloud_lb.create_lb]
}

#was 이니스크립트
resource "ncloud_init_script" "create_was_init" {
  name = "${var.pnoun}-wascon"
  content = templatefile("${path.module}/tomcat.tpl", {
    db_domain = "${ncloud_mysql.create_mysql.mysql_server_list[0].private_domain}"
  })
  depends_on = [ncloud_mysql.create_mysql]
}

#bas nic
resource "ncloud_network_interface" "create_nic_bas" {
  name      = "${var.pnoun}-bas-nic"
  subnet_no = ncloud_subnet.create_bas_subnet.id
  #  private_ip            = cidrsubnet(ncloud_vpc.create_vpc.ipv4_cidr_block, 16, 2560+1)
  access_control_groups = [
    ncloud_access_control_group.create_acg_pub.id,
    ncloud_access_control_group.create_acg_com.id
  ]
}
#bas server
resource "ncloud_server" "create_bas_sv" {
  subnet_no                 = ncloud_subnet.create_bas_subnet.id
  name                      = "${var.pnoun}-bas-sv"
  server_image_product_code = data.ncloud_server_image.server_image.id
  server_product_code       = "SVR.VSVR.HICPU.C002.M004.NET.HDD.B050.G002"
  description               = "${var.pnoun}-bas-sv is best tip!!"
  login_key_name            = ncloud_login_key.create_key.key_name
  # init_script_no = "${ncloud_init_script.create_init.id}"
  network_interface {
    network_interface_no = ncloud_network_interface.create_nic_bas.id
    order                = 0
  }
}
#private server nic                        #안하면 acg안붙음
resource "ncloud_network_interface" "create_nic_pri" {
  count     = length(var.zone)
  name      = "${var.pnoun}-pri-nic-${count.index + 1}"
  subnet_no = ncloud_subnet.create_pri_subnet[count.index].id
  #  private_ip            = "${var.server_pri_CIDR[count.index]}"
  access_control_groups = [
    ncloud_access_control_group.create_acg_pri.id,
    ncloud_access_control_group.create_acg_com.id,
    ncloud_mysql.create_mysql.access_control_group_no_list[0]
  ]
}
#private server
resource "ncloud_server" "create_pri_sv" {
  count                     = length(var.zone)
  subnet_no                 = ncloud_subnet.create_pri_subnet[count.index].id
  name                      = "${var.pnoun}-pri-sv-${count.index + 1}"
  server_image_product_code = data.ncloud_server_image.server_image.id
  server_product_code       = "SVR.VSVR.HICPU.C002.M004.NET.HDD.B050.G002"
  description               = "${var.pnoun}-pri-sv-${count.index + 1} is best tip!!"
  init_script_no            = ncloud_init_script.create_was_init.id
  login_key_name            = ncloud_login_key.create_key.key_name
  network_interface {
    network_interface_no = ncloud_network_interface.create_nic_pri[count.index].id
    order                = 0
  }
}
#pub nic
resource "ncloud_network_interface" "create_nic_pub" {
  count     = length(var.zone)
  name      = "${var.pnoun}-pub-nic-${count.index + 1}"
  subnet_no = ncloud_subnet.create_pub_subnet[count.index].id
  access_control_groups = [
    ncloud_access_control_group.create_acg_pri.id,
    ncloud_access_control_group.create_acg_com.id
  ]
}
#public server
resource "ncloud_server" "create_pub_sv" {
  count                     = length(var.zone)
  subnet_no                 = ncloud_subnet.create_pub_subnet[count.index].id
  name                      = "${var.pnoun}-pub-sv-${count.index + 1}"
  server_image_product_code = data.ncloud_server_image.server_image.id
  server_product_code       = "SVR.VSVR.HICPU.C002.M004.NET.HDD.B050.G002"
  description               = "${var.pnoun}-pub-sv-${count.index + 1} is best tip!!"
  login_key_name            = ncloud_login_key.create_key.key_name
  init_script_no            = ncloud_init_script.create_web_init.id
  network_interface {
    network_interface_no = ncloud_network_interface.create_nic_pub[count.index].id
    order                = 0
  }
}

#db server
resource "ncloud_mysql" "create_mysql" {
  subnet_no                = ncloud_subnet.create_db_subnet[0].id
  service_name             = "${var.pnoun}-mysql"
  server_name_prefix       = var.pnoun
  user_name                = "msp001"
  user_password            = "user123!@#"
  host_ip                  = "%"
  database_name            = "mysql"
  is_ha                    = true
  is_multi_zone            = true
  standby_master_subnet_no = ncloud_subnet.create_db_subnet[1].id
}



resource "ncloud_public_ip" "public-ip" {
  server_instance_no = ncloud_server.create_bas_sv.id
}
data "ncloud_root_password" "root_passwd_pub" {
  count              = length(var.zone)
  server_instance_no = ncloud_server.create_pub_sv[count.index].id
  private_key        = ncloud_login_key.create_key.private_key
}
data "ncloud_root_password" "root_passwd_pri" {
  count              = length(var.zone)
  server_instance_no = ncloud_server.create_pri_sv[count.index].id
  private_key        = ncloud_login_key.create_key.private_key
}

#LB Targetgroup
resource "ncloud_lb_target_group" "create_lb_tg" {
  name        = "${var.pnoun}-lb-tag-web"
  vpc_no      = ncloud_vpc.create_vpc.id
  protocol    = "HTTP"
  target_type = "VSVR"
  port        = 80
  description = "${var.pnoun}-lb-tag-web"
  health_check {
    protocol       = "HTTP"
    http_method    = "GET"
    port           = 80
    url_path       = "/"
    cycle          = 30
    up_threshold   = 2
    down_threshold = 2
  }
  algorithm_type = "RR"
}

#LB targetgorup attachment
resource "ncloud_lb_target_group_attachment" "create_lb_tg_att" {
  target_group_no = ncloud_lb_target_group.create_lb_tg.id
  target_no_list  = ncloud_server.create_pub_sv.*.id
}
#LB
resource "ncloud_lb" "create_lb" {
  name           = "${var.pnoun}-lb-web"
  network_type   = "PUBLIC"
  type           = "APPLICATION"
  subnet_no_list = ncloud_subnet.create_lb_subnet.*.id
}

resource "ncloud_lb_listener" "listener" {
  load_balancer_no = ncloud_lb.create_lb.id
  protocol         = "HTTP"
  port             = 80
  target_group_no  = ncloud_lb_target_group.create_lb_tg.id
}


#LB pri Targetgroup
resource "ncloud_lb_target_group" "create_lb_pri_tg" {
  name        = "${var.pnoun}-lb-pri-tag-web"
  vpc_no      = ncloud_vpc.create_vpc.id
  protocol    = "TCP"
  target_type = "VSVR"
  port        = 8080
  description = "${var.pnoun}-lb-pri-tag-web"
  health_check {
    protocol       = "TCP"
    http_method    = "GET"
    port           = 8080
    url_path       = "/"
    cycle          = 30
    up_threshold   = 2
    down_threshold = 2
  }
  algorithm_type = "RR"
}

#LB pri targetgorup attachment
resource "ncloud_lb_target_group_attachment" "create_lb_pri_tg_att" {
  target_group_no = ncloud_lb_target_group.create_lb_pri_tg.id
  target_no_list  = ncloud_server.create_pri_sv.*.id
}
#LB pri
resource "ncloud_lb" "create_pri_lb" {
  name           = "${var.pnoun}-lb-pri-web"
  network_type   = "PRIVATE"
  type           = "NETWORK"
  subnet_no_list = [ncloud_subnet.create_lb_pri_subnet.id]
}
#lb pri listen 
resource "ncloud_lb_listener" "pri_listener" {
  load_balancer_no = ncloud_lb.create_pri_lb.id
  protocol         = "TCP"
  port             = 8080
  target_group_no  = ncloud_lb_target_group.create_lb_pri_tg.id
}

data "ncloud_lb" "data_pri_lb" {
  id = ncloud_lb.create_pri_lb.id
}
