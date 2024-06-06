#!/bin/bash

# update
dnf update -y

# Enable PasswordAuthentication
sed -i -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Enable PermitRootLogin
sed -i -e 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config

###########################################################################################
#   dnf install oracle-ovirt-release-45-el8 -y
#   dnf install kernel-uek-modules-extra -y
#   reboot
#   dnf install ovirt-engine -y
#   engine-setup --accept-defaults
#   dnf install cockpit-ovirt-dashboard vdsm-gluster -y
#   dnf install oracle-gluster-release-el8 -y
#   dnf install @glusterfs/server -y
#   sudo systemctl enable --now glusterd
#   sudo firewall-cmd --permanent --add-service=glusterfs
#   sudo firewall-cmd --reload
#   /etc/hosts file instead
#   sudo gluster peer probe thanh-host-2
#   sudo gluster peer probe thanh-host-3
#   sudo gluster peer status
#   sudo gluster pool list
#   gluster volume create gluster replica 3 thanh-host-{1,2,3}:/root/gfs-01 force
#   gluster volume start gluster
#   gluster volume info
###########################################################################################