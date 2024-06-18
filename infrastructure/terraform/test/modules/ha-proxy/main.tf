module "aws_ha_proxy" {
  source                  = "./providers/aws"
  count                   = var.target_provider == "aws" ? 1 : 0
}

module "azure_ha_proxy" {
  source                  = "./providers/azure"
  count                   = var.target_provider == "azure" ? 1 : 0
}

module "gcp_ha_proxy" {
  source                  = "./providers/gcp"
  count                   = var.target_provider == "gcp" ? 1 : 0
}

module "kvm_ha_proxy" {
  source                  = "./providers/kvm"
  count                   = var.target_provider == "kvm" ? 1 : 0
}

module "vsphere_resource_vcenter" {
  source                  = "./providers/vsphere/resource-vm"
  count                   = var.target_provider == "vsphere" ? 1 : 0

  vsphere_endpoint        = var.vsphere_endpoint
  vsphere_username        = var.vsphere_username
  vsphere_password        = var.vsphere_password
}

module "vsphere_ha_proxy" {
  source                  = "./providers/vsphere/resource-vm"
  count                   = var.target_provider == "vsphere" ? 1 : 0

  vsphere_endpoint        = var.vsphere_endpoint
  vsphere_username        = var.vsphere_username
  vsphere_password        = var.vsphere_password
  vsphere_datacenter      = var.vsphere_datacenter
  vsphere_cluster         = var.vsphere_cluster
  vsphere_datastore       = var.vsphere_datastore
  vsphere_folder          = var.vsphere_folder
  vsphere_resource_pool   = var.vsphere_resource_pool
  vsphere_network         = var.vsphere_network
  vsphere_vm_template     = var.vsphere_vm_template
  vm_template_firmware    = var.vm_template_firmware

  for_each                = var.ha_proxy_configs

  vm_name                 = each.value.vm_name
  vm_cpu_cores            = each.value.vm_cpu_cores
  vm_mem_size             = each.value.vm_mem_size
  vm_ip_address           = each.value.vm_ip_address

  vm_subnet               = var.vm_subnet
  vm_gateway              = var.vm_gateway
  vm_dns                  = var.vm_dns
  vm_domain_name          = var.vm_domain_name
}
