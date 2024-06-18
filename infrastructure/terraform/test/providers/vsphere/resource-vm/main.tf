provider "vsphere" {
  vsphere_server                    = var.vsphere_endpoint
  user                              = var.vsphere_username
  password                          = var.vsphere_password
  allow_unverified_ssl              = var.vsphere_insecure_connection
}

data "vsphere_datacenter" "target_dc" {
  name                              = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "target_cluster" {
  name                              = var.vsphere_cluster
  datacenter_id                     = data.vsphere_datacenter.target_dc.id
}

data "vsphere_datastore" "target_datastore" {
  name                              = var.vsphere_datastore
  datacenter_id                     = data.vsphere_datacenter.target_dc.id
}

data "vsphere_network" "target_network" {
  name                              = var.vsphere_ds_port_group
  datacenter_id                     = data.vsphere_datacenter.target_dc.id
}

data "vsphere_folder" "target_folder" {
  path                              = "${var.vsphere_datacenter}/vm/${var.vsphere_folder}"
}

data "vsphere_resource_pool" "target_resource_pool" {
  name                              = var.vsphere_resource_pool
  datacenter_id                     = data.vsphere_datacenter.target_dc.id
}

data "vsphere_virtual_machine" "vm_template" {
  name                              = var.vsphere_vm_template
  datacenter_id                     = data.vsphere_datacenter.target_dc.id
}

resource "vsphere_virtual_machine" "vsphere_vm" {
  count                             = length(var.vm_ip_address)
  name                              = "${var.vm_name}-${count.index}"
  datastore_id                      = data.vsphere_datastore.target_datastore.id
  resource_pool_id                  = data.vsphere_resource_pool.target_resource_pool.id
  folder                            = data.vsphere_folder.target_folder.path

  num_cpus                          = var.vm_cpu_cores
  cpu_hot_add_enabled               = var.vm_cpu_hot_add
  cpu_hot_remove_enabled            = var.vm_cpu_hot_remove  
  memory                            = var.vm_mem_size
  memory_hot_add_enabled            = var.vm_mem_hot_add

  efi_secure_boot_enabled           = var.vm_enable_efi
  firmware                          = var.vm_template_firmware

  guest_id                          = data.vsphere_virtual_machine.vm_template.guest_id
  scsi_type                         = data.vsphere_virtual_machine.vm_template.scsi_type

  network_interface {
    network_id                      = data.vsphere_network.target_network.id
    adapter_type                    = data.vsphere_virtual_machine.vm_template.network_interface_types[0]
  }

  disk {
    label                           = "disk0"
    size                            = data.vsphere_virtual_machine.vm_template.disks[0].size
    eagerly_scrub                   = data.vsphere_virtual_machine.vm_template.disks[0].eagerly_scrub
    thin_provisioned                = data.vsphere_virtual_machine.vm_template.disks[0].thin_provisioned
  }

  clone {
    template_uuid                   = data.vsphere_virtual_machine.vm_template.id

    customize {
      linux_options {
        host_name                   = "${var.vm_name}-${count.index}"
        domain                      = var.vm_domain_name
      }

      network_interface {
        ipv4_address                = lookup(var.vm_ip_address, count.index)
        ipv4_netmask                = var.vm_subnet
      }

      ipv4_gateway                  = var.vm_gateway
      dns_server_list               = [var.vm_dns]
    }
  }

  connection {
    type                            = "ssh"
    host                            = self.guest_ip_addresses[0]
    user                            = "root"
    private_key                     = file("${path.root}/spec_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "cat /etc/os-release && uname -a"
    ]
  }
}
