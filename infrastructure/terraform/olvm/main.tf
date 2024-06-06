terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.8.1"
    }
  }
}

provider "vsphere" {
  vsphere_server              = "${var.vsphere_endpoint}"
  user                        = "${var.vsphere_username}"
  password                    = "${var.vsphere_password}"
  allow_unverified_ssl        = "${var.vsphere_insecure_connection}"
}

data "vsphere_datacenter" "target_dc" {
  name                        = "${var.vsphere_datacenter}"
}

data "vsphere_compute_cluster" "target_cluster" {
  name                        = "${var.vsphere_cluster}"
  datacenter_id               = "${data.vsphere_datacenter.target_dc.id}"
}

data "vsphere_datastore" "target_datastore" {
  name                        = "${var.vsphere_datastore}"
  datacenter_id               = "${data.vsphere_datacenter.target_dc.id}"
}

data "vsphere_network" "target_network" {
  name                        = "${var.vsphere_network}"
  datacenter_id               = "${data.vsphere_datacenter.target_dc.id}"
}

data "vsphere_virtual_machine" "oracle_template" {
  name                        = "${var.vsphere_vm_template}"
  datacenter_id               = "${data.vsphere_datacenter.target_dc.id}"
}

locals {
  name_master_node            = "${var.vm_name_prefix}-host"
}

resource "vsphere_folder" "folder" {
  path                        = "${var.vsphere_folder}"
  datacenter_id               = "${data.vsphere_datacenter.target_dc.id}"
  type                        = "vm"
}

resource "vsphere_resource_pool" "resource_pool" {
  name                        = "${var.vsphere_resource_pool}"
  parent_resource_pool_id     = "${data.vsphere_compute_cluster.target_cluster.resource_pool_id}"
}

resource "vsphere_virtual_machine" "oracle_vm" {
  count                       = "${length(var.oracle_vm_ip)}"
  name                        = "${local.name_master_node}-${count.index}"
  resource_pool_id            = "${vsphere_resource_pool.resource_pool.id}"
  datastore_id                = "${data.vsphere_datastore.target_datastore.id}"
  folder                      = "${vsphere_folder.folder.path}"

  num_cpus                    = "${var.oracle_vm_cpu}"
  memory                      = "${var.oracle_vm_ram}"
  
  cpu_hot_add_enabled         = true
  cpu_hot_remove_enabled      = true
  memory_hot_add_enabled      = true
  efi_secure_boot_enabled     = true
  hv_mode                     = "hvOn"
  firmware                    = "${var.vm_template_firmware}"
  guest_id                    = "${data.vsphere_virtual_machine.oracle_template.guest_id}"
  scsi_type                   = "${data.vsphere_virtual_machine.oracle_template.scsi_type}"

  network_interface {
    network_id                = "${data.vsphere_network.target_network.id}"
    adapter_type              = "${data.vsphere_virtual_machine.oracle_template.network_interface_types[0]}"
  }

  disk {
    label                     = "disk0"
    size                      = "${data.vsphere_virtual_machine.oracle_template.disks[0].size}"
    eagerly_scrub             = "${data.vsphere_virtual_machine.oracle_template.disks[0].eagerly_scrub}"
    thin_provisioned          = "${data.vsphere_virtual_machine.oracle_template.disks[0].thin_provisioned}"
  }

  clone {
    template_uuid             = "${data.vsphere_virtual_machine.oracle_template.id}"

    customize {
      linux_options {
        host_name             = "${local.name_master_node}-${count.index}"
        domain                = "${var.oracle_vm_domain_name}"
      }

      network_interface {
        ipv4_address          = "${lookup(var.oracle_vm_ip, count.index)}"
        ipv4_netmask          = "${var.oracle_vm_netmask}"
      }

      ipv4_gateway            = "${var.oracle_vm_gateway}"
      dns_server_list         = ["${var.oracle_vm_dns}"]
    }
  }
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("spec_rsa")
    host        = "${self.guest_ip_addresses[0]}"
  }
    provisioner "file" {
    source      = "files/config_ssh.sh"
    destination = "/root/config_ssh.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/config_ssh.sh && /root/config_ssh.sh"
    ]
  }
}
