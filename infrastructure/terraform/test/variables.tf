/*  
    Defines the input variables from Github Action to BLOCK: build
*/

variable "target_provider" {
  description = "The target provider to use for deployment"
  type        = string
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

variable "vsphere_insecure_connection" {
  type        = bool
  description = "Do not validate vCenter Server TLS certificate."
  default     = true
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

variable "k8s_master_ip" {
  type        = map(any)
  description = "IP of the guest operating system."
}

variable "k8s_master_cpu" {
  type        = number
  description = "The number of virtual CPUs. (e.g. '2')"
}

variable "k8s_master_ram" {
  type        = number
  description = "The size for the virtual memory in MB. (e.g. '2048')"
}

variable "k8s_worker_ip" {
  type        = map(any)
  description = "IP of the guest operating system."
}

variable "k8s_worker_cpu" {
  type        = number
  description = "The number of virtual CPUs cores per socket. (e.g. '1')"
}

variable "k8s_worker_ram" {
  type        = number
  description = "The size for the virtual memory in MB. (e.g. '2048')"
}

variable "k8s_ha_proxy_ip" {
  type        = map(any)
  description = "IP of the guest operating system."
}

variable "k8s_ha_proxy_cpu" {
  type        = number
  description = "The number of virtual CPUs cores per socket. (e.g. '1')"
}

variable "k8s_ha_proxy_ram" {
  type        = number
  description = "The size for the virtual memory in MB. (e.g. '2048')"
}
