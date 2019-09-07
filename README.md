# packer-proxmox-templates
:package: Packer templates for building Proxmox KVM images from ISO

- use the latest tagged version which has been tested more thoroughly than 'master'

#### [Alpine](https://wiki.alpinelinux.org/wiki/Alpine_Linux:Releases)  Linux [Packer Template](https://github.com/chriswayg/packer-proxmox-templates/tree/master/alpine3.10-qemu) using QEMU Builder to build a KVM image usable in Proxmox or Openstack

#### [Debian ](https://www.debian.org/releases/) v10.0 (buster) [Packer Template](https://github.com/chriswayg/packer-proxmox-templates/tree/master/debian-10.0-x86_64-proxmox) using Packer Proxmox Builder to build a Proxmox VM image template

#### [Ubuntu ](http://releases.ubuntu.com/) 18.04 (bionic) [Packer Template](https://github.com/chriswayg/packer-proxmox-templates/tree/master/ubuntu-18.04-amd64-proxmox) using Packer Proxmox Builder to build a Proxmox VM image template

## Proxmox KVM image templates

- downloads the ISO and places it in Proxmox
- creates a Proxmox VM using Packer
- builds the image using preseed.cfg and Ansible
- stores it as a Proxmox Template
- see README for details on each template
