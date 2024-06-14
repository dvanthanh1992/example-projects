terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.8.1"
    }
  }
  required_version = ">= 1.8.0"
}

provider "vsphere" {
  vsphere_server              = "${var.vsphere_endpoint}"
  user                        = "${var.vsphere_username}"
  password                    = "${var.vsphere_password}"
  allow_unverified_ssl        = "${var.vsphere_insecure_connection}"
}

locals {
  k8s_vm_configs = {
    master = {
      vm_name             = "${var.vm_name_prefix}-master"
      vm_cpu_cores        = "${var.k8s_master_cpu}"
      vm_mem_size         = "${var.k8s_master_ram}"
      vm_ip_address       = "${var.k8s_master_ip}"
    }

    worker = {
      vm_name             = "${var.vm_name_prefix}-worker"
      vm_cpu_cores        = "${var.k8s_worker_cpu}"
      vm_mem_size         = "${var.k8s_worker_ram}"
      vm_ip_address       = "${var.k8s_worker_ip}"
    }

    haproxy = {
      vm_name             = "${var.vm_name_prefix}-ha-proxy"
      vm_cpu_cores        = "${var.k8s_ha_proxy_cpu}"
      vm_mem_size         = "${var.k8s_ha_proxy_ram}"
      vm_ip_address       = "${var.k8s_ha_proxy_ip}"
    }
  }
}

module "vsphere_k8s" {
  source                  = "./provider/vsphere"
  for_each                = "${local.k8s_vm_configs}"

  vsphere_datacenter      = "${var.vsphere_datacenter}"
  vsphere_cluster         = "${var.vsphere_cluster}"
  vsphere_datastore       = "${var.vsphere_datastore}"
  vsphere_folder          = "${var.vsphere_folder}"
  vsphere_resource_pool   = "${var.vsphere_resource_pool}"
  vsphere_network         = "${var.vsphere_network}"
  vsphere_vm_template     = "${var.vsphere_vm_template}"
  vm_template_firmware    = "${var.vm_template_firmware}"

  vm_name                 = "${each.value.vm_name}"
  vm_cpu_cores            = "${each.value.vm_cpu_cores}"
  vm_mem_size             = "${each.value.vm_mem_size}"
  vm_ip_address           = "${each.value.vm_ip_address}"

  vm_subnet               = "${var.vm_subnet}"
  vm_gateway              = "${var.vm_gateway}"
  vm_dns                  = "${var.vm_dns}"
  vm_domain_name          = "${var.vm_domain_name}"
}
