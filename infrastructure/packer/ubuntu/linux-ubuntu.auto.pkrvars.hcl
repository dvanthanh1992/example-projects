// vSphere Credentials
vsphere_insecure_connection           = true  

// Guest Operating System Metadata & Virtual Machine Settings
vm_guest_os_language                  = "en_US.UTF-8"
vm_guest_os_keyboard                  = "us"
vm_guest_os_timezone                  = "Asia/Ho_Chi_Minh"
vm_guest_os_type                      = "ubuntu64Guest"
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
iso_paths_01                          = ["[IIJVN-vSAN] Thanh-ISO/ubuntu-20.04.6-live-server-amd64.iso"]
iso_paths_02                          = ["[IIJVN-vSAN] Thanh-ISO/ubuntu-22.04.4-live-server-amd64.iso"]
iso_paths_03                          = ["[IIJVN-vSAN] Thanh-ISO/ubuntu-24.04-live-server-amd64.iso"]

// VM Storage Settings
vm_disk_device                        = "sda"
vm_disk_use_swap                      = false
vm_disk_partitions = [
  {
    name = "efi"
    size = 1024,
    format = {
      label  = "EFIFS",
      fstype = "fat32",
    },
    mount = {
      path    = "/boot/efi",
      options = "",
    },
    volume_group = "",
  },
  {
    name = "boot"
    size = 1024,
    format = {
      label  = "BOOTFS",
      fstype = "xfs",
    },
    mount = {
      path    = "/boot",
      options = "",
    },
    volume_group = "",
  },
  {
    name = "ubuntu-lv"
    size = -1,
    format = {
      label  = "",
      fstype = "",
    },
    mount = {
      path    = "",
      options = "",
    },
    volume_group = "ubuntu-lv",
  },
]
vm_disk_lvm = [
  {
    name : "ubuntu-lv",
    partitions : [
      {
        name = "root",
        size = -1,
        format = {
          label  = "ROOTFS",
          fstype = "xfs",
        },
        mount = {
          path    = "/",
          options = "",
        },
      },
    ],
  }
]
