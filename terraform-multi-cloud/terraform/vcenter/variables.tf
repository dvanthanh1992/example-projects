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
  sensitive   = true
  description = "The password for the login to the vCenter Server instance."
}

variable "vsphere_insecure_connection" {
  type        = bool
  default     = true
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

variable "vsphere_vm_template_name" {
  type        = string
  description = "Name of VM template used to create the vSphere virtual machines"
}

// Virtual Machine Settings
variable "number_vms" {
  type        = string
  description = "The number of virtual machines to deploy from the vApp template."
}

variable "vm_name_prefix" {
  type        = string
  description = "The guest operating system name. Used for naming."
}

variable "base_vm_ip_cidr" {
  type        = string
  description = "The base IP address in CIDR notation (e.g., 192.168.1.0/24) for assigning static IPs to virtual machines."
}

variable "vm_gateway" {
  type        = string
  description = "Gateway of the guest operating system."
}

variable "vm_dns" {
  type        = string
  description = "DNS of the guest operating system."
}

variable "vm_cpu_cores" {
  type        = number
  description = "The number of virtual CPUs cores per socket for VM. (e.g. '1')"
}

variable "vm_mem_size" {
  type        = number
  description = "The size for the virtual memory in MB for VM. (e.g. '2048')"
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

variable "vm_mem_hot_add" {
  type        = bool
  description = "Enable hot add memory."
  default     = true
}

variable "vm_enable_efi" {
  type        = bool
  default     = true
  description = "Use this option to enable EFI secure boot when the firmware type is set to is efi."
}

variable "vm_template_firmware" {
  type        = string
  default     = "efi"
  description = "The virtual machine template firmware. (e.g. 'efi-secure'. 'efi', or 'bios')"
}

variable "selenium_node_count" {
  type        = string
  description = "The number of Selenium Node containers to be deployed. Each container runs an instance of Selenium Node. Adjust this value to scale the testing infrastructure."
}

variable "selenium_hub_ip" {
  type        = string
  description = "The IP address of the Selenium Hub to which Selenium Nodes will connect. Ensure this IP is reachable by the nodes in the same network environment."
}
