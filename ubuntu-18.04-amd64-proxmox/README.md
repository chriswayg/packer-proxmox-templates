## [Ubuntu ](http://releases.ubuntu.com/18.04/) 18.04 (bionic) Packer Template using [Packer Proxmox Builder](https://www.packer.io/docs/builders/proxmox.html) to build a Proxmox KVM image template

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

### Check Prerequisites

The build script which will run the packer template is *configured to run on the Proxmox server*. Thus the following pre-requisites should be installed on the Proxmox server:

- [Proxmox 6](https://www.proxmox.com/en/downloads)

- [Packer](https://www.packer.io/downloads.html)

```
apt -y install unzip
packer_ver=1.4.3
wget https://releases.hashicorp.com/packer/${packer_ver}/packer_${packer_ver}_linux_amd64.zip
unzip packer_${packer_ver}_linux_amd64.zip -d /usr/local/bin
packer --version
```

- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) 2.7.10

```
apt -y install python3-pip
pip3 install ansible==2.7.10
```

- [j2cli](https://github.com/kolypto/j2cli) `pip3 install j2cli` or `pip3 install j2cli[yaml]`

### Download the latest release of packer-proxmox-templates

`wget https://github.com/chriswayg/packer-proxmox-templates/archive/v1.3.zip && unzip v1.3.zip`

### Usage

On the Proxmox Server with Packer installed:

- edit `build.conf`, especially the Proxmox URL & ISO download links (for the latest distro version)
- edit `playbook/server-template-vars.yml`, especially the SSH Key & repos

```
cd packer-proxmox-templates-1.3/ubuntu-18.04-amd64-proxmox

../build.sh proxmox
```

- The finished template can be checked in the Proxmox GUI
- Login using the default username as set in `build.conf`

### Build Options

```sh
../build.sh (proxmox|debug [new_VM_ID])

proxmox    - Build and create a Proxmox VM template
debug      - Debug Mode: Build and create a Proxmox VM template

VM_ID     - VM ID for new VM template (or use default from build.conf)

Enter Passwwords when prompted or provide them via ENV variables:
(use a space in front of ' export' to keep passwords out of bash_history)
 export proxmox_password=MyLoginPassword
 export ssh_password=MyPasswordInVM
```

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
