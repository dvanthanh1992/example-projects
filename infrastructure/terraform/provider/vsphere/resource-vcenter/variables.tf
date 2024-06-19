/*  
    Defines the input variables from Github Action to BLOCK: build
*/

// vSphere Settings

variable "vsphere_datacenter" {
  type        = string
  description = "The name of the target vSphere Datacenter."
}

variable "vsphere_cluster" {
  type        = string
  description = "The name of the target vSphere Cluster."
}

variable "vsphere_ds_switch" {
  type        = string
  description = "The name of the target vSphere Distributed Switches (VDS)."
  default     = "DSwitch_v7.0.0"
}

variable "vsphere_pg_vlan_id" {
  type        = number
  description = "Identifies the VLAN ID of vSphere network segment."
  default     = 0
}

variable "vsphere_ds_port_group" {
  type        = string
  description = "The name of the target vSphere network segment."
}

variable "vsphere_folder" {
  type        = string
  description = "The name of the target vSphere Folder."
}

variable "vsphere_resource_pool" {
  type        = string
  description = "The name of the target vSphere resource pool."
}
