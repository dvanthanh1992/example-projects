#cloud-config
# Ubuntu Server 20.04 LTS

autoinstall:
  version: 1

  apt:
    geoip: true
    preserve_sources_list: false
    primary:
      - arches: [amd64, i386]
        uri: http://archive.ubuntu.com/ubuntu
      - arches: [default]
        uri: http://ports.ubuntu.com/ubuntu-ports

  early-commands:
    - sudo systemctl stop ssh

  locale: ${build_vm_guest_os_language}

  keyboard:
    layout: ${build_vm_guest_os_keyboard}

  user-data:
    timezone: ${build_vm_guest_os_timezone}
    disable_root: false
    ssh_authorized_keys:
      - ${build_vm_public_key}

  identity:
    hostname: ${build_vm_hostname}
    username: root
    password: ${build_vm_password_encrypted}

  ssh:
    install-server: true
    allow-pw: true

  network:
    network:
      version: 2
      renderer: networkd
      ethernets:
        ${build_vm_network_device}:
          dhcp4: false
          dhcp6: false
          addresses:
            - ${build_vm_ip}/${build_vm_subnet}
          gateway4: ${build_vm_gateway}
          nameservers:
            addresses:
              - ${build_vm_dns}
${build_vm_storage}

  packages:
    - openssh-server
    - open-vm-tools
    - cloud-init
