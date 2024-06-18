/*  
    Defines the input variables from Github Action
*/



// Locals Settings

variable "target_provider" {
  description = "The target provider to use for deployment"
  type        = string
}

variable "ha_proxy_configs" {
  description = "Map of HAProxy configurations"
  type = map(object({
    vm_name       = string
    vm_cpu_cores  = number
    vm_mem_size   = number
    vm_ip_address = string
  }))
}

variable "k8s_cluster_configs" {
  description = "Map of Kubernetes cluster configurations"
  type = map(object({
    vm_name       = string
    vm_cpu_cores  = number
    vm_mem_size   = number
    vm_ip_address = string
  }))
}

// vSphere Credentials

variable "vsphere_endpoint" {
  type        = string
  description = "The fully qualified domain name or IP address of the vCenter Server instance."
}

variable "vsphere_username" {
  type        = string
  description = "The username to login to the vCenter Server instance."
}

variable "vsphere_password" {
  type        = string
  description = "The password for the login to the vCenter Server instance."
}

// vSphere Settings

variable "vsphere_datacenter" {
  type        = string
  description = "The name of the target vSphere Datacenter."
}

variable "vsphere_cluster" {
  type        = string
  description = "The name of the target vSphere Cluster."
}

variable "vsphere_datastore" {
  type        = string
  description = "The name of the target vSphere Datastore."
}

variable "vsphere_folder" {
  type        = string
  description = "The name of the target vSphere Folder."
}

variable "vsphere_resource_pool" {
  type        = string
  description = "The name of the target vSphere resource pool."
}

variable "vsphere_network" {
  type        = string
  description = "The name of the target vSphere network segment."
}

variable "vsphere_vm_template" {
  description = "Template used to create the vSphere virtual machines"
}

variable "vm_template_firmware" {
  type        = string
  description = "The virtual machine template firmware. (e.g. 'efi-secure'. 'efi', or 'bios')"
}

// Virtual Machine Settings

variable "vm_name_prefix" {
  type        = string
  description = "The guest operating system name. Used for naming."
}

variable "vm_dns" {
  type        = string
  description = "DNS of the guest operating system."
}

variable "vm_domain_name" {
  type        = string
  description = "DNS of the guest operating system."
}

variable "vm_subnet" {
  type        = string
  description = "Subnet of the guest operating system."
}

variable "vm_gateway" {
  type        = string
  description = "Gateway of the guest operating system."
}
