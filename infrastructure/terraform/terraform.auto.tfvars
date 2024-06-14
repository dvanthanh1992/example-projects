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
vsphere_vm_template                   = "..."
*/

// Virtual Machine k8s Settings
vm_template_firmware                  = "efi"
vm_name_prefix                        = "thanh-k8s"
vm_subnet                             = "24"
vm_gateway                            = "192.168.137.1"            
vm_dns                                = "192.168.137.200"
vm_domain_name                        = "lab.local"

k8s_master_cpu                        = "4"
k8s_master_ram                        = "8192"
k8s_master_ip = {
  "0"                                 = "192.168.137.21"
}

k8s_worker_cpu                        = "4"
k8s_worker_ram                        = "8192"
k8s_worker_ip = {
  "0"                                 = "192.168.137.22"
  "1"                                 = "192.168.137.23"
}

k8s_ha_proxy_cpu                      = "2"
k8s_ha_proxy_ram                      = "4096"
k8s_ha_proxy_ip = {
  "0"                                 = "192.168.137.20"
}
