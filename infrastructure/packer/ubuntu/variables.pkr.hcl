/*  
    Input variables.
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

// Virtual Machine Settings

variable "vm_network_device" {
  type        = string
  description = "The network device of the VM."
  default     = "ens192"
}

variable "vm_ip_address" {
  type        = string
  description = "IP of the guest operating system."
}

variable "vm_netmask" {
  type        = string
  description = "Netmask of the guest operating system."
}

variable "vm_gateway" {
  type        = string
  description = "Gateway of the guest operating system."
}

variable "vm_dns" {
  type        = string
  description = "DNS of the guest operating system."
}

variable "vm_guest_os_name" {
  type        = string
  description = "The guest operating system name. Used for naming."
}

variable "vm_guest_os_version" {
  type        = string
  description = "The guest operating system version. Used for naming."
}

variable "vm_guest_os_language" {
  type        = string
  description = "The guest operating system lanugage."
}

variable "vm_guest_os_keyboard" {
  type        = string
  description = "The guest operating system keyboard input."
}

variable "vm_guest_os_timezone" {
  type        = string
  description = "The guest operating system timezone."
}

variable "vm_guest_os_type" {
  type        = string
  description = "The guest operating system type, also know as guestid. (e.g. 'rhel9_64Guest')"
}

variable "vm_firmware" {
  type        = string
  description = "The virtual machine firmware. (e.g. 'efi-secure'. 'efi', or 'bios')"
}

variable "vm_cpu_count" {
  type        = number
  description = "The number of virtual CPUs. (e.g. '2')"
}

variable "vm_cpu_cores" {
  type        = number
  description = "The number of virtual CPUs cores per socket. (e.g. '1')"
}

variable "vm_cpu_hot_add" {
  type        = bool
  description = "Enable hot add CPU."
}

variable "vm_mem_size" {
  type        = number
  description = "The size for the virtual memory in MB. (e.g. '2048')"
}

variable "vm_mem_hot_add" {
  type        = bool
  description = "Enable hot add memory."
}

variable "vm_disk_controller_type" {
  type        = list(string)
  description = "The virtual disk controller types in sequence. (e.g. 'pvscsi')"
}

variable "vm_disk_size" {
  type        = number
  description = "The size for the virtual disk in MB. (e.g. '40960')"
}

variable "vm_disk_thin_provisioned" {
  type        = bool
  description = "Thin provision the virtual disk."
}

variable "vm_network_card_type" {
  type        = string
  description = "The virtual network card type.(e.g. 'vmxnet3')"
}

variable "vm_version" {
  type        = number
  description = "The vSphere virtual hardware version. (e.g. '19')"
}

variable "vm_usb_controller" {
  type        = list(string)
  description = "Create USB controllers for the virtual machine. 'usb' for a usb 2.0 controller. 'xhci' for a usb 3.0 controller."
}

variable "vm_remove_cdrom" {
  type        = bool
  description = "Remove the virtual CD-ROM(s)."
}

variable "vm_tools_upgrade_policy" {
  type        = string
  description = "If sets to true, vSphere will automatically check and upgrade VMware Tools upon a system power cycle. If not set, defaults to manual upgrade."
}

variable "iso_paths_01" {
  type        = list(string)
  description = "List of Datastore or Content Library paths to ISO files that will be mounted to the VM."
}

variable "iso_paths_02" {
  type        = list(string)
  description = "List of Datastore or Content Library paths to ISO files that will be mounted to the VM."
}

// Boot and Provisioning Settings

variable "common_template_conversion" {
  type        = bool
  description = "Convert the virtual machine to template. Must be 'false' for content library."
  default     = false
}

variable "common_data_source" {
  type        = string
  description = "The provisioning data source. (e.g. 'http' or 'disk')"
}

variable "common_vm_boot_order" {
  type        = string
  description = "The boot order for virtual machines devices. (e.g. 'disk,cdrom')"
  default     = "disk,cdrom"
}

variable "common_vm_boot_wait" {
  type        = string
  description = "The time to wait before boot."
}

variable "common_ip_wait_timeout" {
  type        = string
  description = "Time to wait for guest operating system IP address response."
}

variable "common_shutdown_timeout" {
  type        = string
  description = "Time to wait for guest operating system shutdown."
}

// Communicator Settings and Credentials

variable "communicator_user" {
  type        = string
  description = "The username to login to the guest operating system."
}

variable "communicator_password_encrypted" {
  type        = string
  description = "The SHA-512 encrypted root password to login to the guest operating system."
}

variable "communicator_private_key" {
  type        = string
  description = "The private key to login to the guest operating system."
}

variable "communicator_public_key" {
  type        = string
  description = "The public key to login to the guest operating system."
}

variable "communicator_port" {
  type        = string
  description = "The port for the communicator protocol."
}

variable "communicator_timeout" {
  type        = string
  description = "The timeout for the communicator protocol."
}

// VM Storage Settings

variable "vm_disk_device" {
  type        = string
  description = "The device for the virtual disk. (e.g. 'sda')"
}

variable "vm_disk_use_swap" {
  type        = bool
  description = "Whether to use a swap partition."
}

variable "vm_disk_partitions" {
  type = list(object({
    name = string
    size = number
    format = object({
      label  = string
      fstype = string
    })
    mount = object({
      path    = string
      options = string
    })
    volume_group = string
  }))
  description = "The disk partitions for the virtual disk."
}

variable "vm_disk_lvm" {
  type = list(object({
    name = string
    partitions = list(object({
      name = string
      size = number
      format = object({
        label  = string
        fstype = string
      })
      mount = object({
        path    = string
        options = string
      })
    }))
  }))
  description = "The LVM configuration for the virtual disk."
  default     = []
}