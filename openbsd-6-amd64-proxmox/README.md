## OpenBSD 6.6 Packer Template using [Packer Proxmox Builder](https://www.packer.io/docs/builders/proxmox.html) to build a Proxmox KVM image template

Status: **working well**

- downloads the ISO and places it in Proxmox
- creates a Proxmox VM
- builds the image using install.conf and Ansible
- stores it as a Proxmox Template

### Configurations
- there is no qemu guest agent for Packer SSH, therefore we use a static local IP during installation via Packer
- passwordless doas for default user 'deploy' (name can be changed in build.conf)
- SSH public key installed for default user
- display IP and SSH fingerprint before console login (not yet implemented)
- generates new SSH host keys on first boot to avoid duplicates in cloned VMs
- OpenBSD has no cloud utils with growpart to automatically grow partition after resize by Proxmox

### Instructions

- [README with Prerequisites and Usage](https://github.com/chriswayg/packer-proxmox-templates/blob/master/README.md)
