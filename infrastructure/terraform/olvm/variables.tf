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

variable "vsphere_network" {
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

variable "vsphere_vm_template" {
  description = "Template used to create the vSphere virtual machines"
}

variable "vm_name_prefix" {
  type        = string
  description = "The guest operating system name. Used for naming."
}

variable "vm_template_firmware" {
  type        = string
  description = "The virtual machine template firmware. (e.g. 'efi-secure'. 'efi', or 'bios')"
}

// Virtual Machine Settings

variable "oracle_vm_netmask" {
  type        = string
  description = "Netmask of the guest operating system."
}

variable "oracle_vm_gateway" {
  type        = string
  description = "Gateway of the guest operating system."
}

variable "oracle_vm_dns" {
  type        = string
  description = "DNS of the guest operating system."
}

variable "oracle_vm_domain_name" {
  description = "DNS of the guest operating system."
}

variable "oracle_vm_ip" {
  type        = map(any)
  description = "IP of the guest operating system."
}

variable "oracle_vm_cpu" {
  type        = number
  description = "The number of virtual CPUs cores per socket. (e.g. '1')"
}

variable "oracle_vm_ram" {
  type        = number
  description = "The size for the virtual memory in MB. (e.g. '2048')"
}
