## [Alpine Linux](http://alpinelinux.org) Packer Template using [Packer Proxmox Builder](https://www.packer.io/docs/builders/proxmox.html) to build a Proxmox KVM image template

Status: **working**

### Features
- downloads the ISO and places it in Proxmox
- creates a Proxmox VM
- builds the image using an answers file and bash scripts
- stores it as a Proxmox Template

### Configurations
- passwordless sudo for default user 'christian'
- SSH public key installed for default user
- display IP and SSH fingerprint before console login
- automatically grow partition after resize by Proxmox

### Instructions
- [REAMDE with Prerequisites and Usage](https://github.com/chriswayg/packer-proxmox-templates/blob/master/README.md)

### Docs
- [Semi-Automatic Installation - Alpine Linux Documentation](https://beta.docs.alpinelinux.org/user-handbook/0.1a/Installing/manual.html)


### License and Credits
- Apache 2.0 Copyright 2019 Christian Wagner
- partially based on Matt Maier's [Packer Alpine Templates](https://github.com/maier/packer-templates)
