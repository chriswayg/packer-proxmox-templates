# packer-proxmox-templates
:package: Packer templates for building Proxmox KVM images from ISO

### [Alpine Linux](http://alpinelinux.org) Packer Template using QEMU Builder to build a KVM image usable in Proxmox or Openstack

### [Debian ](http://debian.org) v10.0 (buster) Packer Template using Packer Proxmox Builder to build a Proxmox VM image template

#### Prereq

- Packer
- Ansible
- j2cli
```
# Packer Install:

apt install python3-pip
pip3 install ansible==2.7.10
pip3 install j2cli[yaml]
```
