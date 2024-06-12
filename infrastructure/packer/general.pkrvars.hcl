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

/*
Boot and Provisioning Settings
common_vm_boot_order                  = "-"
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
communicator_password_encrypted       = "$6$JzgZuih8VZs34Hoa$ZoEsNAdROez2p73shQRI.YdM32.aLp2zWy3JuKo56vIBZWBTsjp/gNZobYgQc59rGSDNctx.PdtsXDRvdMsiz."
communicator_private_key              = "spec_rsa"
communicator_public_key               = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtv/lh8wd7/n97TEe/rCdMOmcm0a/R7QueArWlPIzw0Vyk8fRvLjUnFbof+OA+PMKRBN8xn7PrRM5tatf+AU66IMjgWx01Ou36+YTr3szQLtnIZ0qkyE00szU4luxU+b3vwI88LcldXbgKbJZOAYkdr5HMx50m4vHY0dszklWQfHirp45wberXSxD/tEoHhjEVNNdxoaqJzgSQ1D4gU1Xh7yg34yCdzt/tKmvpJGf4+Lr/3NR2Jykhdjz0Wad9JQvyj1Ldu9GLhTDoLz1VjMdS/sksaS2R0S5Jht/cK+18NjzEquRdTFlCBRaLw54Zj5/qA+26yMqpYtcD7L50UTZxmvQNRAt0WWnthn1TyZ5GKfHGsJbQwRKbAwEa9e4yUwh9N9XMG7F61hvuEnYAAz0k+cksJxQe9BtyJfDbkuKRjrMt9sd/ThN8HVBOG+TmHfFExTQss/srsgGqRoEGjVXKtLYWSgYYLcH3NBw/i7cnoSkAJOCQzenlBLxc1Ug3vF0="
communicator_port                     = "22"
communicator_timeout                  = "60m"
