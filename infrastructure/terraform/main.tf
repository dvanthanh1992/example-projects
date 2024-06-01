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

data "vsphere_virtual_machine" "k8s_ubuntu_template" {
  name                        = "${var.vsphere_vm_template}"
  datacenter_id               = "${data.vsphere_datacenter.target_dc.id}"
}

locals {
  name_master_node            = "${var.vm_name_prefix}-master"
  name_worker_node            = "${var.vm_name_prefix}-worker"
  name_ha_proxy_node          = "${var.vm_name_prefix}-ha-proxy"
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

resource "vsphere_virtual_machine" "k8s_master" {
  count                       = "${length(var.k8s_master_ip)}"
  name                        = "${local.name_master_node}-${count.index}"
  resource_pool_id            = "${vsphere_resource_pool.resource_pool.id}"
  datastore_id                = "${data.vsphere_datastore.target_datastore.id}"
  folder                      = "${vsphere_folder.folder.path}"

  num_cpus                    = "${var.k8s_master_cpu}"
  memory                      = "${var.k8s_master_ram}"
  
  cpu_hot_add_enabled         = true
  cpu_hot_remove_enabled      = true
  memory_hot_add_enabled      = true
  efi_secure_boot_enabled     = true

  firmware                    = "${var.vm_template_firmware}"
  guest_id                    = "${data.vsphere_virtual_machine.k8s_ubuntu_template.guest_id}"
  scsi_type                   = "${data.vsphere_virtual_machine.k8s_ubuntu_template.scsi_type}"

  network_interface {
    network_id                = "${data.vsphere_network.target_network.id}"
    adapter_type              = "${data.vsphere_virtual_machine.k8s_ubuntu_template.network_interface_types[0]}"
  }

  disk {
    label                     = "disk0"
    size                      = "${data.vsphere_virtual_machine.k8s_ubuntu_template.disks[0].size}"
    eagerly_scrub             = "${data.vsphere_virtual_machine.k8s_ubuntu_template.disks[0].eagerly_scrub}"
    thin_provisioned          = "${data.vsphere_virtual_machine.k8s_ubuntu_template.disks[0].thin_provisioned}"
  }

  clone {
    template_uuid             = "${data.vsphere_virtual_machine.k8s_ubuntu_template.id}"

    customize {
      linux_options {
        host_name             = "${local.name_master_node}-${count.index}"
        domain                = "${var.k8s_domain_name}"
      }

      network_interface {
        ipv4_address          = "${lookup(var.k8s_master_ip, count.index)}"
        ipv4_netmask          = "${var.k8s_netmask}"
      }

      ipv4_gateway            = "${var.k8s_gateway}"
      dns_server_list         = ["${var.k8s_dns}"]
    }
  }
}

resource "vsphere_virtual_machine" "k8s_worker" {
  count                       = "${length(var.k8s_worker_ip)}"
  name                        = "${local.name_worker_node}-${count.index}"
  resource_pool_id            = "${vsphere_resource_pool.resource_pool.id}"
  datastore_id                = "${data.vsphere_datastore.target_datastore.id}"
  folder                      = "${vsphere_folder.folder.path}"

  num_cpus                    = "${var.k8s_worker_cpu}"
  memory                      = "${var.k8s_worker_ram}"
  
  cpu_hot_add_enabled         = true
  cpu_hot_remove_enabled      = true
  memory_hot_add_enabled      = true
  efi_secure_boot_enabled     = true

  firmware                    = "${var.vm_template_firmware}"
  guest_id                    = "${data.vsphere_virtual_machine.k8s_ubuntu_template.guest_id}"
  scsi_type                   = "${data.vsphere_virtual_machine.k8s_ubuntu_template.scsi_type}"

  network_interface {
    network_id                = "${data.vsphere_network.target_network.id}"
    adapter_type              = "${data.vsphere_virtual_machine.k8s_ubuntu_template.network_interface_types[0]}"
  }

  disk {
    label                     = "disk0"
    size                      = "${data.vsphere_virtual_machine.k8s_ubuntu_template.disks[0].size}"
    eagerly_scrub             = "${data.vsphere_virtual_machine.k8s_ubuntu_template.disks[0].eagerly_scrub}"
    thin_provisioned          = "${data.vsphere_virtual_machine.k8s_ubuntu_template.disks[0].thin_provisioned}"
  }

  clone {
    template_uuid             = "${data.vsphere_virtual_machine.k8s_ubuntu_template.id}"

    customize {
      linux_options {
        host_name             = "${local.name_worker_node}-${count.index}"
        domain                = "${var.k8s_domain_name}"
      }

      network_interface {
        ipv4_address          = "${lookup(var.k8s_worker_ip, count.index)}"
        ipv4_netmask          = "${var.k8s_netmask}"
      }

      ipv4_gateway            = "${var.k8s_gateway}"
      dns_server_list         = ["${var.k8s_dns}"]
    }
  }
  connection {
    type        = "ssh"
    user        = "root"
    password    = "VMware1!"
    host        = "${self.guest_ip_addresses[0]}"
  }
    provisioner "file" {
    source      = "main.tf"
    destination = "/root/main.tf"
  }
}

resource "vsphere_virtual_machine" "k8s_ha_proxy" {
  count                       = "${length(var.k8s_ha_proxy_ip)}"
  name                        = "${local.name_ha_proxy_node}-${count.index}"
  resource_pool_id            = "${vsphere_resource_pool.resource_pool.id}"
  datastore_id                = "${data.vsphere_datastore.target_datastore.id}"
  folder                      = "${vsphere_folder.folder.path}"

  num_cpus                    = "${var.k8s_ha_proxy_cpu}"
  memory                      = "${var.k8s_ha_proxy_ram}"
  
  cpu_hot_add_enabled         = true
  cpu_hot_remove_enabled      = true
  memory_hot_add_enabled      = true
  efi_secure_boot_enabled     = true

  firmware                    = "${var.vm_template_firmware}"
  guest_id                    = "${data.vsphere_virtual_machine.k8s_ubuntu_template.guest_id}"
  scsi_type                   = "${data.vsphere_virtual_machine.k8s_ubuntu_template.scsi_type}"

  network_interface {
    network_id                = "${data.vsphere_network.target_network.id}"
    adapter_type              = "${data.vsphere_virtual_machine.k8s_ubuntu_template.network_interface_types[0]}"
  }

  disk {
    label                     = "disk0"
    size                      = "${data.vsphere_virtual_machine.k8s_ubuntu_template.disks[0].size}"
    eagerly_scrub             = "${data.vsphere_virtual_machine.k8s_ubuntu_template.disks[0].eagerly_scrub}"
    thin_provisioned          = "${data.vsphere_virtual_machine.k8s_ubuntu_template.disks[0].thin_provisioned}"
  }

  clone {
    template_uuid             = "${data.vsphere_virtual_machine.k8s_ubuntu_template.id}"

    customize {
      linux_options {
        host_name             = "${local.name_ha_proxy_node}-${count.index}"
        domain                = "${var.k8s_domain_name}"
      }

      network_interface {
        ipv4_address          = "${lookup(var.k8s_ha_proxy_ip, count.index)}"
        ipv4_netmask          = "${var.k8s_netmask}"
      }

      ipv4_gateway            = "${var.k8s_gateway}"
      dns_server_list         = ["${var.k8s_dns}"]
    }
  }
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("spec_rsa")
    host        = "${self.guest_ip_addresses[0]}"
  }
    provisioner "file" {
    source      = "main.tf"
    destination = "/root/main.tf"
  }
}
