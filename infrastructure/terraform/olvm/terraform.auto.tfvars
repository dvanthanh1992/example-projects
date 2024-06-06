/* Input from Github Action Workflow & file .env
vsphere_endpoint                      = "..."
vsphere_username                      = "..."
vsphere_password                      = "..."
vsphere_datacenter                    = "..."
vsphere_cluster                       = "..."
vsphere_datastore                     = "..."
vsphere_folder                        = "..."
vsphere_resource_pool                 = "..."
vsphere_network                       = "..."
oracle_vm_netmask                     = "..." /24
oracle_vm_gateway                     = "..."
oracle_vm_dns                         = "..."
oracle_vm_domain_name                 = "..."
*/

// vSphere Credentials
vsphere_insecure_connection           = true
// Guest Operating System Metadata & Virtual Machine Settings
vsphere_vm_template                   = "oracle8"
vm_template_firmware                  = "efi"
vm_name_prefix                        = "thanh"
oracle_vm_cpu                         = "4"
oracle_vm_ram                         = "8192"
oracle_vm_ip = {
  "0"                                 = "192.168.137.30"
  "1"                                 = "192.168.137.31"
  "2"                                 = "192.168.137.32"
  "3"                                 = "192.168.137.33"
}
