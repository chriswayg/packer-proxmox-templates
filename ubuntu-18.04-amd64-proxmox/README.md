## [Ubuntu ](http://releases.ubuntu.com/18.04/) 18.04 (bionic) Packer Template using Packer Proxmox Builder to build a Proxmox KVM image template

- downloads the ISO from Ubuntu and places it in Proxmox
- creates a Proxmox VM
- builds the image with preseed.cfg and scripts
- stores it as a Proxmox Template

### Use

On the Proxmox Server with Packer installed:

```
cd packer-proxmox-templates/ubuntu-18.04.3-amd64-proxmox

 ../build.sh proxmox
```

The finished template (default 34000) can be seen in the Proxmox GUI

### Command Options

```sh
../build.sh (proxmox|debug [new_VM_ID])

proxmox    - Build and create a Proxmox VM template
debug      - Debug Mode: Build and create a Proxmox VM template

new_VM_ID  - Optional VM ID for new VM template. Default [33000]
```

### Update ISO download link

in `build.conf`

#### Build environment

```sh
packer version && pveversion && lsb_release -d && cat /etc/debian_version
		Packer v1.4.3
		pve-manager/6.0-5/f8a710d7 (running kernel: 5.0.18-1-pve)
		Description:	Debian GNU/Linux 10 (buster)
		10.0
```
