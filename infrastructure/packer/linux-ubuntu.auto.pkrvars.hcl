/* Input from Github Action Workflow & file .env
vsphere_endpoint                      = "..."
vsphere_username                      = "..."
vsphere_password                      = "..."
vsphere_datacenter                    = "..."
vsphere_cluster                       = "..."
vsphere_folder                        = "..."
vsphere_resource_pool                 = "..."
vsphere_datastore                     = "..."
vsphere_network                       = "..."
vm_ip_address                         = "..."
vm_netmask                            = "..."
vm_gateway                            = "..."
vm_dns                                = "..."

*/

// vSphere Credentials
vsphere_insecure_connection     = true  

// Guest Operating System Metadata & Virtual Machine Settings
vm_guest_os_name                = "ubuntu"
vm_guest_os_version             = "20-04-lts"
vm_guest_os_language            = "en_US.UTF-8"
vm_guest_os_keyboard            = "us"
vm_guest_os_timezone            = "Asia/Ho_Chi_Minh"
vm_guest_os_type                = "ubuntu64Guest"
vm_guest_os_cloudinit           = false
vm_firmware                     = "efi-secure"
vm_cpu_count                    = 4
vm_cpu_cores                    = 2
vm_cpu_hot_add                  = true
vm_mem_size                     = "8192"
vm_mem_hot_add                  = true
vm_disk_controller_type         = ["pvscsi"] 
vm_disk_size                    = "61440"
vm_disk_thin_provisioned        = true
vm_network_card_type            = "vmxnet3"
vm_version                      = "19"
vm_usb_controller               = ["xhci"]
vm_remove_cdrom                 = true
vm_tools_upgrade_policy         = true
iso_paths                       = ["[IIJVN-vSAN] Thanh-ISO/ubuntu-20.04.6-live-server-amd64.iso"]

// VM Storage Settings
vm_disk_device                  = "sda"
vm_disk_use_swap                = false
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


/*
Boot and Provisioning Settings
Link refer : https://github.com/vmware-samples/packer-examples-for-vsphere/issues/814#issuecomment-1913254835
*/ 
common_data_source                    = "disk"   
common_template_conversion            = true
common_vm_boot_order                  = "disk,cdrom"
common_vm_boot_wait                   = "5s"
common_ip_wait_timeout                = "15m"
common_shutdown_timeout               = "15m"

// Communicator Settings and Credentials
// apt-get install whois && mkpasswd --method=SHA-512 --rounds=4096
communicator_user                     = "root"
communicator_password_encrypted       = "$6$rounds=4096$kP7oOU66OAo$ZsxkowLJ3LfM39r.wOazePFjfYf.Wn2w.zwIQFV6NpbyiDAwsmFQ3PWYJFkl8WHCePR2SGChR6Q5fEWmtaeIN."
communicator_private_key              = "spec_rsa"
communicator_public_key               = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtv/lh8wd7/n97TEe/rCdMOmcm0a/R7QueArWlPIzw0Vyk8fRvLjUnFbof+OA+PMKRBN8xn7PrRM5tatf+AU66IMjgWx01Ou36+YTr3szQLtnIZ0qkyE00szU4luxU+b3vwI88LcldXbgKbJZOAYkdr5HMx50m4vHY0dszklWQfHirp45wberXSxD/tEoHhjEVNNdxoaqJzgSQ1D4gU1Xh7yg34yCdzt/tKmvpJGf4+Lr/3NR2Jykhdjz0Wad9JQvyj1Ldu9GLhTDoLz1VjMdS/sksaS2R0S5Jht/cK+18NjzEquRdTFlCBRaLw54Zj5/qA+26yMqpYtcD7L50UTZxmvQNRAt0WWnthn1TyZ5GKfHGsJbQwRKbAwEa9e4yUwh9N9XMG7F61hvuEnYAAz0k+cksJxQe9BtyJfDbkuKRjrMt9sd/ThN8HVBOG+TmHfFExTQss/srsgGqRoEGjVXKtLYWSgYYLcH3NBw/i7cnoSkAJOCQzenlBLxc1Ug3vF0="
communicator_port                     = "22"
communicator_timeout                  = "60m"
