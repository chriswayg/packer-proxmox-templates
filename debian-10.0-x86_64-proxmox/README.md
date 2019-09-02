## [Debian ](http://debian.org) v10.0 (buster) Packer Template using Packer Proxmox Builder to build a Proxmox KVM image template

- downloads the ISO from Debian and places it in Proxmox
- creates a Proxmox VM
- builds the image using preseed.cfg and Ansible
- stores it as a Proxmox Template

### Configurations
- qemu-guest-agent for Packer SSH and in Proxmox for shutdown and backups
- haveged random number generator speeds up boot
- passwordless sudo for default user: 'deploy' (name can be changed in build.conf)
- SSH public key installed for default user
- display IP and SSH fingerprint before login
- automatically grow partition after resize by Proxmox

### Use

On the Proxmox Server with Packer installed:

```
cd packer-proxmox-templates/debian-10.0.0-x86_64-proxmox

 ../build.sh proxmox
```

- The finished template (default 33000) can be seen in the Proxmox GUI
- Login using the default username as set in build.conf

### Command Options

```sh
../build.sh (proxmox|debug [new_VM_ID])

proxmox    - Build and create a Proxmox VM template
debug      - Debug Mode: Build and create a Proxmox VM template

VM_ID     - VM ID for new VM template (or use default from build.conf)

 export proxmox_password=MyLoginPassword (or enter it when prompted)
```

### Update ISO download links

in `build.conf`

#### Build environment

```sh
printf  "$(lsb_release -d) $(cat /etc/debian_version)\n" && \
  printf  "Proxmox $(pveversion)\n" &&
  packer version && \
  ansible --version |  sed -n '1p' && \
  j2 --version

      Description:	Debian GNU/Linux 10 (buster) 10.0
      Proxmox pve-manager/6.0-5/f8a710d7 (running kernel: 5.0.18-1-pve)
      Packer v1.4.3
      ansible 2.7.10
      j2cli 0.3.10, Jinja2 2.10.1

```
