## [Alpine Linux](http://alpinelinux.org) Packer Template using QEMU Builder to build a KVM cloud image usable in Proxmox or Openstack

* this creates a cloud image with cloud-init to be used on Proxmox and possibly Openstack

### Prerequisites
- qemu-system-x86_64
- packer

### Usage notes

```sh
cd alpine3.10-qemu
sudo packer build alpine-3.10-x86_64-qemu.json
```
- The image is output as `alpine-310-cloudimg-amd64.qcow2` in the current directory

- Test the image locally:

```sh
genisoimage -output cloud-data.iso -volid cidata -joliet -rock user-data meta-data

sudo qemu-system-x86_64 alpine-310-cloudimg-amd64.qcow2 -netdev  user,id=user.0,hostfwd=tcp::2222-:22 -device  virtio-net,netdev=user.0 -cdrom cloud-data.iso

ssh -i alpine_id_rsa -p 2222 alpine@localhost
```
- To install the image as a template on Proxmox, the following script can be used:
- [Script to download a cloud image and create a Proxmox 6 template](https://gist.github.com/chriswayg/43fbea910e024cbe608d7dcb12cb8466)

### Features
- default user alpine
- SSH login only via SHH key
- passwordless sudo
- no root login via console or ssh
- add user-data via image drive

### cloud-init on Alpine
- is not quite complete

#### Working
- getting user and metadata from image drive
- setting hostname (1st boot)
- setting up user (1st boot)
- copying SSH authorized keys (1st boot)
- automatically growing the disk drive with growpart
  - `qm resize 8000 scsi0 +30G` upon restart

#### Not working (apparently)
- writing of network config
- password for user (not entered into `/etc/shadow`)
- changed data on image-drive is not applied after 1st boot

### Fulfills most Openstack requirements

For a Linux-based image to have full functionality in an OpenStack Compute cloud, there are a few requirements. For some of these, you can fulfill the requirements by installing the  [cloud-init](https://cloudinit.readthedocs.org/en/latest/)  package.

* Disk partitions and resize root partition on boot (cloud-init)
* No hard-coded MAC address information
* SSH server running
* Disable firewall
* Access instance using ssh public key (cloud-init)
* Process user data and other metadata (cloud-init)

[OpenStack Docs: Image requirements](https://docs.openstack.org/image-guide/openstack-images.html)

### Docs
- [Semi-Automatic Installation - Alpine Linux Documentation](https://beta.docs.alpinelinux.org/user-handbook/0.1a/Installing/manual.html)
- [OpenStack Docs: Create images manually](https://docs.openstack.org/image-guide/create-images-manually.html)

### Build environment

```sh
packer version && qemu-system-x86_64 -version && lsb_release -d

    Packer v1.4.3
    QEMU emulator version 2.11.1
    Ubuntu 18.04.3 LTS
```

### License and Credits
- Apache 2.0 Copyright 2019 Christian Wagner
- partially based on Matt Maier's [Packer Alpine Templates](https://github.com/maier/packer-templates)
