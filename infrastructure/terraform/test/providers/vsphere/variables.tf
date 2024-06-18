/*  
    Defines the input variables from Github Action to BLOCK: build
*/

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

variable "vsphere_vm_template" {
  description = "Template used to create the vSphere virtual machines"
}

// Virtual Machine Settings

variable "vm_name" {
  type        = string
  description = "The guest operating system name. Used for naming."
}

variable "vm_cpu_cores" {
  type        = number
  description = "The number of virtual CPUs cores per socket. (e.g. '1')"
}

variable "vm_cpu_hot_add" {
  type        = bool
  description = "Enable hot add CPU."
  default     = true
}

variable "vm_cpu_hot_remove" {
  type        = bool
  description = "Allow CPUs to be removed to the virtual machine while it is powered on."
  default     = true
}

variable "vm_mem_size" {
  type        = number
  description = "The size for the virtual memory in MB. (e.g. '2048')"
}

variable "vm_mem_hot_add" {
  type        = bool
  description = "Enable hot add memory."
  default     = true
}

variable "vm_enable_efi" {
  type        = bool
  description = "Use this option to enable EFI secure boot when the firmware type is set to is efi."
  default     = true
}

variable "vm_template_firmware" {
  type        = string
  description = "The virtual machine template firmware. (e.g. 'efi-secure'. 'efi', or 'bios')"
}

variable "vm_ip_address" {
  type        = map(any)
  description = "IP of the guest operating system."
}

variable "vm_subnet" {
  type        = string
  description = "Subnet of the guest operating system."
}

variable "vm_gateway" {
  type        = string
  description = "Gateway of the guest operating system."
}

variable "vm_dns" {
  type        = string
  description = "DNS of the guest operating system."
}

variable "vm_domain_name" {
  type        = string
  description = "DNS of the guest operating system."
}
