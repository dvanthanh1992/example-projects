//  BLOCK: locals
//  Defines the local variables.

packer {
  required_plugins {
    vsphere = {
      version = "~> 1"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

locals {
  build_vm_name                       = "Template-${var.vm_guest_os_name}-${var.vm_guest_os_version}"
  build_os_distribution               = "${var.vm_guest_os_name}-${var.vm_guest_os_version}"
  build_by                            = "Built by: HashiCorp Packer"
  build_date                          = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  build_description                   = "Built on: ${local.build_date}\n${local.build_by}"
  build_iso_paths                     = "${local.build_os_distribution}" == "oracle-8" ? "${var.iso_paths_01}" : "${var.iso_paths_02}"
  data_source_command                 = "${var.common_data_source}" == "http" ? "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg" : "inst.ks=cdrom:/ks.cfg"
  data_source_content                 = {
    "/ks.cfg" = templatefile("${abspath(path.root)}/data/ks.pkrtpl.hcl", {
      build_vm_hostname               = "${var.vm_hostname}"
      build_vm_ip                     = "${var.vm_ip_address}"
      build_vm_netmask                = "${var.vm_netmask}"
      build_vm_gateway                = "${var.vm_gateway}"
      build_vm_dns                    = "${var.vm_dns}"
      build_vm_password_encrypted     = "${var.communicator_password_encrypted}"
      build_vm_public_key             = "${var.communicator_public_key}"
      vm_guest_os_language            = "${var.vm_guest_os_language}"
      vm_guest_os_keyboard            = "${var.vm_guest_os_keyboard}"
      vm_guest_os_timezone            = "${var.vm_guest_os_timezone}"
    })
  }
}

//  BLOCK: source
//  Defines the builder configuration blocks.

source "vsphere-iso" "oracle-linux" {

  // vCenter Server Endpoint Settings and Credentials
  vcenter_server                = "${var.vsphere_endpoint}"
  username                      = "${var.vsphere_username}"
  password                      = "${var.vsphere_password}"
  insecure_connection           = "${var.vsphere_insecure_connection}"

  // vSphere Settings
  datacenter                    = "${var.vsphere_datacenter}"
  cluster                       = "${var.vsphere_cluster}"
  datastore                     = "${var.vsphere_datastore}"
  folder                        = "${var.vsphere_folder}"
  resource_pool                 = "${var.vsphere_resource_pool}"

  // Virtual Machine Settings
  vm_name                       = "${local.build_vm_name}"
  notes                         = "${local.build_description}"  
  guest_os_type                 = "${var.vm_guest_os_type}"
  firmware                      = "${var.vm_firmware}"
  CPUs                          = "${var.vm_cpu_count}"
  cpu_cores                     = "${var.vm_cpu_cores}"
  CPU_hot_plug                  = "${var.vm_cpu_hot_add}"
  RAM                           = "${var.vm_mem_size}"
  RAM_hot_plug                  = "${var.vm_mem_hot_add}"
  disk_controller_type          = "${var.vm_disk_controller_type}"
  storage {
    disk_size                   = "${var.vm_disk_size}"
    disk_thin_provisioned       = "${var.vm_disk_thin_provisioned}"
  }
  network_adapters {
    network                     = "${var.vsphere_network}"
    network_card                = "${var.vm_network_card_type}"
  }
  vm_version                    = "${var.vm_version}"
  usb_controller                = "${var.vm_usb_controller}"
  remove_cdrom                  = "${var.vm_remove_cdrom}"
  tools_upgrade_policy          = "${var.vm_tools_upgrade_policy}"
  iso_paths                     = "${local.build_iso_paths}"

  // Template Settings
  convert_to_template           = "${var.common_template_conversion}"

  // Boot and Provisioning Settings 
  http_content                  = "${var.common_data_source}" == "http" ? "${local.data_source_content}" : null
  cd_content                    = "${var.common_data_source}" == "disk" ? "${local.data_source_content}" : null
  boot_command                  = [
    "<up>",
    "e",
    "<down><down><end><wait>",
    "text ${local.data_source_command}",
    "<enter><wait><leftCtrlOn>x<leftCtrlOff>"
  ]
  boot_order                    = "${var.common_vm_boot_order}"
  boot_wait                     = "${var.common_vm_boot_wait}"
  ip_wait_timeout               = "${var.common_ip_wait_timeout}"
  shutdown_timeout              = "${var.common_shutdown_timeout}"
  shutdown_command              = "init 0"

  // OS Connection Details
  communicator                  = "ssh"
  ssh_host                      = "${var.vm_ip_address}"
  ssh_username                  = "${var.communicator_user}"
  ssh_private_key_file          = "${var.communicator_private_key}"
  ssh_port                      = "${var.communicator_port}"
  ssh_timeout                   = "${var.communicator_timeout}"
}

//  BLOCK: build
//  Defines the builders to run, provisioners, and post-processors.

build {
  sources                       = ["source.vsphere-iso.oracle-linux"]

  post-processor "manifest" {
    output                      = "../manifests/manifest.json"
    strip_path                  = true
    strip_time                  = true
    custom_data = {
      os_distribution           = "${local.build_os_distribution}"
    }
  }
}
