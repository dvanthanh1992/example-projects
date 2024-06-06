// vSphere Credentials
vsphere_insecure_connection           = true

// Guest Operating System Metadata & Virtual Machine Settings
# check ks.pkrtpl.hcl - dnf install -y oracle-epel-release-el8 ???
vm_guest_os_name                      = "oracle"
vm_guest_os_version                   = "8"
vm_guest_os_language                  = "en_US.UTF-8"
vm_guest_os_keyboard                  = "us"
vm_guest_os_timezone                  = "Asia/Ho_Chi_Minh"
vm_guest_os_type                      = "oracleLinux8_64Guest"
vm_firmware                           = "efi-secure"
vm_cpu_count                          = 2
vm_cpu_cores                          = 2
vm_cpu_hot_add                        = true
vm_mem_size                           = "4096"
vm_mem_hot_add                        = true
vm_disk_controller_type               = ["pvscsi"]
vm_disk_size                          = "61440"
vm_disk_thin_provisioned              = true
vm_network_card_type                  = "vmxnet3"
vm_version                            = "19"
vm_usb_controller                     = ["xhci"]
vm_remove_cdrom                       = true
vm_tools_upgrade_policy               = true
iso_paths                             = ["[IIJVN-vSAN] Thanh-ISO/OracleLinux-R8-U10-x86_64-dvd.iso"]
