/*

Terraform module which create vApp VM ressources on VMWare Cloud Director.

*/
terraform {
  required_version = ">= 1.8.0"
  required_providers {
    vcd = {
      source = "vmware/vcd"
      version = "3.13.0"
    }
  }
}

provider "vcd" {
  url                  = "${var.vcd_url_api}/api"
  user                 = "none"
  password             = "none"
  auth_type            = "api_token"
  api_token            = var.vcd_api_token
  allow_unverified_ssl = var.disable_ssl_verification
  org                  = var.vcd_org_name
  vdc                  = var.vcd_vdc_name
}

data "vcd_catalog" "vm_template_catalog" {
  org                           = var.vcd_org_name
  name                          = var.vcd_catalog_name
}

data "vcd_catalog_vapp_template" "vm_template" {
  org                           = var.vcd_org_name
  name                          = var.vcd_vapp_template_name
  catalog_id                    = data.vcd_catalog.vm_template_catalog.id
}

resource "vcd_vm" "performance_testing_system" {
  count                         = var.number_vms
  vapp_template_id              = data.vcd_catalog_vapp_template.vm_template.id
  name                          = "${var.vm_name_prefix}-${format("%02d", count.index + 1)}"
  computer_name                 = "${var.vm_name_prefix}-${format("%02d", count.index + 1)}"
  cpus                          = var.vm_cpu_cores
  memory                        = var.vm_mem_size
  guest_properties              = {
    "guest.hostname"            = "${var.vm_name_prefix}-${format("%02d", count.index + 1)}"
  }

  network {
    name                        = var.vcd_vm_network_card
    type                        = "org"
    adapter_type                = "VMXNET3"
    ip_allocation_mode          = "MANUAL"
    ip                          = cidrhost(var.base_vm_ip_cidr,
                                  tonumber(split(".", 
                                           split("/", var.base_vm_ip_cidr)[0])[3]) 
                                           + count.index + 1)                                 
    connected                   = true
  }

  connection {
    type                        = "ssh"
    host                        = cidrhost(var.base_vm_ip_cidr,
                                         tonumber(split(".", 
                                                  split("/", var.base_vm_ip_cidr)[0])[3]) 
                                                  + count.index + 1)
    user                        = "root"
    private_key                 = file("${path.root}/../files/ssh_key")
  }

  provisioner "file" {
    source                      = "${path.root}/../files/selenium_node.sh"
    destination                 = "/root/selenium_node.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "cat /etc/os-release && uname -a",
      "sleep 30",
      "chmod +x /root/selenium_node.sh",
      "bash selenium_node.sh install ${var.selenium_node_count} ${var.selenium_hub_ip}",
      "bash selenium_node.sh start ${var.selenium_node_count} ${var.selenium_hub_ip}",
    ]
  }
}
