data "ncloud_root_password" "root_passwd_bas" {
  server_instance_no = ncloud_server.create_bas_sv.id
  private_key        = ncloud_login_key.create_key.private_key
}

resource "null_resource" "file_ansible_inventory" {
  connection {
    type     = "ssh"
    user     = "root"
    password = data.ncloud_root_password.root_passwd_bas.root_password
    host     = ncloud_server.create_bas_sv.public_ip
  }
  provisioner "file" {
    content = templatefile("./inventory.tpl", {
      zone       = length(var.zone),
      pub_name   = ncloud_server.create_pub_sv.*.name,
      pub_ip     = [for server in ncloud_server.create_pub_sv : server.network_interface[0].private_ip]
      pub_passwd = data.ncloud_root_password.root_passwd_pub.*.root_password
      pri_name   = ncloud_server.create_pri_sv.*.name,
      pri_ip     = [for server in ncloud_server.create_pri_sv : server.network_interface[0].private_ip]
      pri_passwd = data.ncloud_root_password.root_passwd_pri.*.root_password
    })
    destination = "/tmp/inventory.ini"
  }
  provisioner "file" {
    source      = "${path.module}/index.html"
    destination = "/tmp/index.html"
  }
  depends_on = [
    ncloud_server.create_bas_sv,
    data.ncloud_root_password.root_passwd_bas
  ]
}

resource "null_resource" "file_ansible_core" {
  connection {
    type     = "ssh"
    user     = "root"
    password = data.ncloud_root_password.root_passwd_bas.root_password
    host     = ncloud_server.create_bas_sv.public_ip
  }
  provisioner "file" {
    content = templatefile("./mysql.tpl", {
      db_domain = ncloud_mysql.create_mysql.mysql_server_list[0].private_domain,
      db_name   = var.db_config[2],
      db_user   = var.db_config[0],
      db_passwd = var.db_config[1]
    })
    destination = "/tmp/mysql.jsp"
  }
  provisioner "file" {
    source      = "${path.module}/was.yml"
    destination = "/tmp/was.yml"
  }
  provisioner "file" {
    content = templatefile("${path.module}/web.yml", {
      domain = ncloud_lb.create_pri_lb.domain
    })
    destination = "/tmp/web.yml"
  }
  provisioner "remote-exec" {
    inline = [
      "dnf install -y ansible-core",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /tmp/inventory.ini /tmp/was.yml",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /tmp/inventory.ini /tmp/web.yml",
    ]
  }
  depends_on = [ncloud_mysql.create_mysql,
    ncloud_lb.create_lb,
    null_resource.file_ansible_inventory
  ]
}
