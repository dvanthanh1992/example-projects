// Input from Github Action Workflow & file .env
vsphere_endpoint                      = "..."
vsphere_username                      = "..."
vsphere_password                      = "..."
vsphere_datacenter                    = "..."
vsphere_cluster                       = "..."
vsphere_datastore                     = "..."
vsphere_folder                        = "..."
vsphere_resource_pool                 = "..."
vsphere_network                       = "..."
k8s_netmask                           = "..."
k8s_gateway                           = "..."
k8s_dns                               = "..."
k8s_domain_name                       = "..."
vsphere_vm_template                   = "..."
// Input from Github Action Workflow & file .env

// vSphere Credentials
vsphere_insecure_connection           = true
vm_template_firmware                  = "efi"

// Guest Operating System Metadata & Virtual Machine Settings
vm_name_prefix                        = "thanh-k8s"
k8s_ha_proxy_cpu                      = "2"
k8s_ha_proxy_ram                      = "4096"
k8s_ha_proxy_ip = {
  "0"                                 = "192.168.137.20"
}

k8s_master_cpu                        = "4"
k8s_master_ram                        = "4096"
k8s_master_ip = {
  "0"                                 = "192.168.137.21"
}

k8s_worker_cpu                        = "4"
k8s_worker_ram                        = "8192"
k8s_worker_ip = {
  "0"                                 = "192.168.137.22"
  "1"                                 = "192.168.137.23"
}
