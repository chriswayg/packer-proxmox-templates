## [Ubuntu ](http://releases.ubuntu.com/20.04/) 20.04 (focal) Packer Template using [Packer Proxmox Builder](https://www.packer.io/docs/builders/proxmox.html) to build a Proxmox KVM image template

Status: **working well** 

- downloads the ISO and places it in Proxmox
- creates a Proxmox VM
- builds the image using preseed.cfg and Ansible
- stores it as a Proxmox Template

### Configurations
- qemu-guest-agent for Packer SSH and in Proxmox for shutdown and backups
- haveged random number generator to speed up boot
- passwordless sudo for default user 'deploy' (name can be changed in build.conf)
- SSH public key installed for default user
- display IP and SSH fingerprint before console login
- generates new SSH host keys on first boot to avoid duplicates in cloned VMs
- automatically grow partition after resize by Proxmox

### Instructions

- [REAMDE with Prerequisites and Usage](https://github.com/chriswayg/packer-proxmox-templates/blob/master/README.md)
