provider "vsphere" {
  vsphere_server                      = var.vsphere_endpoint
  user                                = var.vsphere_username
  password                            = var.vsphere_password
  allow_unverified_ssl                = var.vsphere_insecure_connection
}

data "vsphere_datacenter" "target_dc" {
  name                                = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "target_cluster" {
  name                                = var.vsphere_cluster
  datacenter_id                       = data.vsphere_datacenter.target_dc.id
}

data "vsphere_distributed_virtual_switch" "target_vds" {
  name                                = var.vsphere_ds_switch
  datacenter_id                       = data.vsphere_datacenter.target_dc.id
}

resource "vsphere_distributed_port_group" "target_pg" {
  name                                = var.vsphere_ds_port_group
  distributed_virtual_switch_uuid     = data.vsphere_distributed_virtual_switch.target_vds.id
  vlan_id                             = var.vsphere_pg_vlan_id
}

resource "vsphere_folder" "target_folder" {
  path                                = var.vsphere_folder
  datacenter_id                       = data.vsphere_datacenter.target_dc.id
  type                                = "vm"
}

resource "vsphere_resource_pool" "target_resource_pool" {
  name                                = var.vsphere_resource_pool
  parent_resource_pool_id             = data.vsphere_compute_cluster.target_cluster.resource_pool_id
}
