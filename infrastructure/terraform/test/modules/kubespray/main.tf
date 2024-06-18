terraform {
  required_version = ">= 1.8.0"
}

resource "local_file" "ansible_inventory" {
    content = templatefile("../artifacts/k8s_hosts.tpl",
    {
        master_ip = values(module.ec2_master)[*].private_ip
        worker_ip = values(module.ec2_workers)[*].private_ip
        nfs_ip = values(module.ec2_private_db)[*].private_ip

    })
    filename = "../inventory"
}

resource "template_file" "haproxy_config" {
  template = file("${path.root}/files/haproxy.cfg.tpl")
  vars = {
    master_ips = [for master in local.k8s_vm_configs.master : master.vm_ip_address]
    worker_ips = [for worker in local.k8s_vm_configs.worker : worker.vm_ip_address]
  }
}

resource "local_file" "haproxy_cfg" {
  content  = template_file.haproxy_config.rendered
  filename = "haproxy.cfg"
}

resource "null_resource" "install_haproxy" {
  depends_on = [module.vsphere_k8s]

  connection {
    type     = "ssh"
    host     = local.k8s_vm_configs.haproxy.vm_ip_address
    user     = "root"
    private_key = file("${path.root}/spec_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update -y",
      "apt-get install -y haproxy",
      "echo '${local_file.haproxy_cfg.content}' > /etc/haproxy/haproxy.cfg",
      "systemctl restart haproxy"
    ]
  }
}
