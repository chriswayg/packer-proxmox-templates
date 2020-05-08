# packer-proxmox-templates
:package: Packer templates for building Proxmox KVM images from ISO

- use the latest tagged version which has been tested more thoroughly than 'master'

#### [Debian ](https://www.debian.org/releases/) v10 (buster) [Packer Template](https://github.com/chriswayg/packer-proxmox-templates/tree/master/debian-10-amd64-proxmox) using Packer Proxmox Builder to build a Proxmox VM image template

#### [Ubuntu ](http://releases.ubuntu.com/) 18.04 (bionic) [Packer Template](https://github.com/chriswayg/packer-proxmox-templates/tree/master/ubuntu-18.04-amd64-proxmox) using Packer Proxmox Builder to build a Proxmox VM image template

#### [Ubuntu ](http://releases.ubuntu.com/) 20.04 (focal) [Packer Template](https://github.com/chriswayg/packer-proxmox-templates/tree/master/ubuntu-20.04-amd64-proxmox) using Packer Proxmox Builder to build a Proxmox VM image template

#### [OpenBSD ](https://www.openbsd.org/index.html) 6 [Packer Template](https://github.com/chriswayg/packer-proxmox-templates/tree/master/openbsd-6-amd64-proxmox) using Packer Proxmox Builder to build a Proxmox VM image template

#### [Alpine](https://wiki.alpinelinux.org/wiki/Alpine_Linux:Releases)  Linux [Packer Template](https://github.com/chriswayg/packer-proxmox-templates/tree/master/alpine-3-amd64-proxmox) using Packer Proxmox Builder to build a Proxmox VM image template

#### [Alpine](https://wiki.alpinelinux.org/wiki/Alpine_Linux:Releases)  Linux [Packer Template](https://github.com/chriswayg/packer-proxmox-templates/tree/master/alpine-3-amd64-qemu) using QEMU Builder to build a KVM image usable in Openstack or Proxmox

## Proxmox KVM image templates

- downloads the ISO and places it in Proxmox
- creates a Proxmox VM
- builds the image with Packer using automated installs
- configures the image with Packer using Ansible
- stores it as a Proxmox Template
- see specific README.md for details about each template

### Check Prerequisites

The build script which will run the packer template is *configured to run on the Proxmox server*. Thus the following pre-requisites should be installed on the Proxmox server:

- Ensure that [Proxmox 6](https://www.proxmox.com/en/downloads) is installed
- Set up a DHCP server on `vmbr1`, for example `isc-dhcp-server`  (see section [DHCP](https://github.com/chriswayg/ansible-proxmox/blob/master/tasks/main.yml) in the Proxmox Ansible role).

```
printf  "Proxmox $(pveversion)\n"
```

- Install [Packer](https://www.packer.io/downloads.html) on the Proxmox server

```
apt -y install unzip
packer_ver=1.5.5
wget https://releases.hashicorp.com/packer/${packer_ver}/packer_${packer_ver}_linux_amd64.zip
sudo unzip packer_${packer_ver}_linux_amd64.zip -d /usr/local/bin
packer --version
```

- Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) on the Proxmox server

```
apt -y install python3-pip
pip3 install ansible==2.9.7
pip3 install py-bcrypt
```

- Install [j2cli](https://github.com/kolypto/j2cli) on the Proxmox server

```
pip3 install j2cli[yaml]
```

### Download the latest tagged release of packer-proxmox-templates onto the Proxmox server

`wget https://github.com/chriswayg/packer-proxmox-templates/archive/v1.7.zip && unzip v1.7.zip && cd packer-proxmox-templates-*`

### Usage

On the Proxmox Server with Packer installed:

```
cd OSname-xy-amd64-proxmox

# for example
cd debian-10-amd64-proxmox
cd ubuntu-18.04-amd64-proxmox
cd openbsd-6-amd64-proxmox

```

- edit `build.conf`, including the default user and especially the Proxmox URL and the ISO download links for the latest distro version
- edit `playbook/server-template-vars.yml`, especially the SSH Key & regional repositories

```sh
../build.sh proxmox
```

- The template creation can be observed in the Proxmox GUI
- Login via SSH using the default username as set in `build.conf`, or login as root via console (if not disabled)

### Build Options

```sh
../build.sh (proxmox|debug [new_VM_ID])

proxmox    - Build and create a Proxmox VM template
debug      - Debug Mode: Build and create a Proxmox VM template

VM_ID     - VM ID for new VM template (or use default from build.conf)

Enter Passwords when prompted or provide them via ENV variables:
(use a space in front of ' export' to keep passwords out of bash_history)
 export proxmox_password=MyLoginPassword
 export ssh_password=MyPasswordInVM
```

#### Build environment

The Packer templates have been tested with the following versions of Packer and Ansible. If you use different versions, some details may need to be updated.

```sh
printf  "$(lsb_release -d) $(cat /etc/debian_version)\n" && \
  printf  "Proxmox $(pveversion)\n" &&
  packer version && \
  ansible --version |  sed -n '1p' && \
  ansible --version |  sed -n '6p' && \
  j2 --version

        Description:	Debian GNU/Linux 10 (buster) 10.3
        Proxmox pve-manager/6.1-8/806edfe1 (running kernel: 5.3.18-3-pve)
        Packer v1.5.5
        ansible 2.9.7
          python version = 3.7.3 (default, Dec 20 2019, 18:57:59) [GCC 8.3.0]
        j2cli 0.3.10, Jinja2 2.11.2
```

**NOTE:** For security reasons it would be preferable to build the Proxmox template images on a local Proxmox staging server (for example in a VM) and then to transfer the Proxmox templates using migration onto the live server(s).

It should also be possible to use Packer remotely and to control VM creation remotely via Ansible. The Packer template and the scripts would have to be modified accordingly. If you have it working remotely, please make a pull request.
