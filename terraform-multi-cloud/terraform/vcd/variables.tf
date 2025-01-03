/*
    DESCRIPTION:
    The following variables are used to configure
    the VMware Cloud Director Provider and define VM deployment parameters.
*/

// VCD Credentials and Settings

variable "vcd_url_api" {
  type        = string
  description = "The URL for the VMware Cloud Director API endpoint. For example, https://server.domain.com."
}

variable "vcd_api_token" {
  type        = string
  sensitive   = true
  description = "The API Token associated with the organization for VMware Cloud Director API access."
}

variable "disable_ssl_verification" {
  type        = bool
  default     = true
  description = "A boolean flag to disable SSL certificate verification. Set to 'true' to bypass SSL checks."
}

variable "vcd_org_name" {
  type        = string
  description = "The name of the organization in VMware Cloud Director on which API operations will be performed."
}

variable "vcd_vdc_name" {
  type        = string
  description = "The name of the Virtual Data Center (VDC) within Cloud Director where resources will be deployed."
}

variable "vcd_catalog_name" {
  type        = string
  description = "The name of the catalog where the vApp template is stored within VMware Cloud Director."
}

variable "vcd_vapp_template_name" {
  type        = string
  description = "The name of the vApp template to be used for deploying virtual machines."
}

variable "vcd_vm_network_card" {
  type        = string
  description = "The name of the network that the deployed virtual machine(s) will be connected to."
}

// Virtual Machine Settings
variable "number_vms" {
  type        = string
  description = "The number of virtual machines to deploy from the vApp template."
}

variable "vm_name_prefix" {
  type        = string
  description = "The base name for the virtual machines to be deployed. Names will be suffixed with incremental numbers (e.g., vm-base-01, vm-base-02)."
}

variable "base_vm_ip_cidr" {
  type        = string
  description = "The base IP address in CIDR notation (e.g., 192.168.1.0/24) for assigning static IPs to virtual machines."
}

variable "vm_cpu_cores" {
  type        = number
  description = "The number of virtual CPUs cores per socket for VM. (e.g. '1')"
}

variable "vm_mem_size" {
  type        = number
  description = "The size for the virtual memory in MB for VM. (e.g. '2048')"
}

variable "selenium_node_count" {
  type        = string
  description = "The number of Selenium Node containers to be deployed. Each container runs an instance of Selenium Node. Adjust this value to scale the testing infrastructure."
}

variable "selenium_hub_ip" {
  type        = string
  description = "The IP address of the Selenium Hub to which Selenium Nodes will connect. Ensure this IP is reachable by the nodes in the same network environment."
}
