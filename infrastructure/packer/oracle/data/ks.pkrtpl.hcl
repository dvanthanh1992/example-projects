# Oracle Linux Server 9

### Installs from the first attached CD-ROM/DVD on the system.
cdrom

### Performs the kickstart installation in text mode. 
### By default, kickstart installations are performed in graphical mode.
text

### Sets the language to use during installation and the default language to use on the installed system.
lang ${vm_guest_os_language}

### Sets the default keyboard type for the system.
keyboard ${vm_guest_os_keyboard}

### Configure network information for target system and activate network devices in the installer environment (optional)
### --onboot	  enable device at a boot time
### --device	  device to be activated and / or configured with the network command
### --bootproto	  method to obtain networking configuration for device (default dhcp)
### --noipv6	  disable IPv6 on this device
### network --onboot=yes --device=ens192 --bootproto=static --ip=192.168.137.171 --netmask=255.255.255.0 --gateway=192.168.137.1 --nameserver=192.168.137.200 --hostname=rhel-9
### network --bootproto=dhcp
network --onboot=yes --device=ens192 --bootproto=static --ip=${build_vm_ip} --netmask=${build_vm_netmask} --gateway=${build_vm_gateway} --nameserver=${build_vm_dns} --hostname=${build_vm_hostname}

### Lock the root account.
### rootpw --lock
rootpw --iscrypted ${build_vm_password_encrypted}

### Configure firewall settings for the system.
### --enabled	reject incoming connections that are not in response to outbound requests
### --ssh       allow sshd service through the firewall
firewall --enabled --ssh

### Sets up the authentication options for the system.
### The SSDD profile sets sha512 to hash passwords. Passwords are shadowed by default
### See the manual page for authselect-profile for a complete list of possible options.
authselect select sssd

### Sets the system time zone.
timezone ${vm_guest_os_timezone}

### Initialize any invalid partition tables found on disks.
zerombr

### Removes partitions from the system, prior to creation of new partitions. 
### By default, no partitions are removed.
### --linux	erases all Linux partitions.
### --initlabel Initializes a disk (or disks) by creating a default disk label for all disks in their respective architecture.
clearpart --all --initlabel --disklabel=gpt

### Modify logical volume sizes for the virtual machine hardware.
### Create primary system partitions.
part /boot --fstype xfs --size=1024 --label=BOOTFS
part /boot/efi --fstype vfat --size=1024 --label=EFIFS
part pv.01 --size=1 --grow

### Create a logical volume management (LVM) group.
volgroup oracle pv.01

### Modify logical volume sizes for the virtual machine hardware.
### Create logical volumes.
logvol / --fstype xfs --name=lv_root --vgname=oracle --label=ROOTFS --percent=100

### The bootloader Kickstart command is required by Redhat
### https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/performing_an_advanced_rhel_9_installation/
bootloader --location=mbr --append="crashkernel=auto rhgb quiet"

### Modifies the default set of services that will run under the default runlevel.
services --enabled=NetworkManager,sshd

### Do not configure X on the installed system.
skipx

### Packages selection.
%packages --ignoremissing --excludedocs
@core
-iwl*firmware
%end

### Post-installation commands
%post --log=/root/ks-post.log
dnf install -y oracle-epel-release-el8
dnf makecache
dnf install -y sudo open-vm-tools perl

### Set PublicKey
mkdir /root/.ssh
cat << '__EOT__' > /root/.ssh/authorized_keys
${build_vm_public_key}
__EOT__
chmod 600 /root/.ssh/authorized_keys

%end

### Reboot after the installation is complete.
### --eject attempt to eject the media before rebooting.
reboot --eject
