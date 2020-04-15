## [Alpine Linux](http://alpinelinux.org) Packer Template using QEMU Builder to build a KVM cloud image usable in Proxmox or Openstack

Status: **working**

* this creates a cloud image with cloud-init to be used on Proxmox and possibly Openstack

### Prerequisites

1) Packer 1.5.5 requires a recent qemu version with gtk support and fails on Ubuntu 18.04. Therefore install a current qemu from source.

- Install qemu build dependencies

```
sudo apt autoremove
sudo apt purge qemu

#sudo apt-get install build-essential pkg-config libglib2.0-dev  libpixman-1-dev libgtk-3-dev
sudo apt-get build-dep qemu
sudo apt-get install libgtk-3-dev checkinstall
```

- Build and install qemu 4.2.0

```
wget https://download.qemu.org/qemu-4.2.0.tar.xz
tar xvJf qemu-4.2.0
cd qemu-4.2.0
./configure --target-list=x86_64-softmmu --enable-gtk
make
sudo checkinstall
```

2) Install packer (see pre-reqs in main README)

### Usage notes

```sh
cd alpine-3-amd64-qemu
sudo packer build alpine-3-amd64-qemu.json
```
- The image is saved as `alpine-311-cloudimg-amd64.qcow2` in the `output` directory

- Test the image locally:
  - adapt `user-data` and `meta-data` as needed
  - login as root on the console. Password: alpineqemu
  - login via ssh

```sh
genisoimage -output output/cloud-data.iso -volid cidata -joliet -rock user-data meta-data

sudo qemu-system-x86_64 output/alpine-311-cloudimg-amd64.qcow2 -netdev  user,id=user.0,hostfwd=tcp::2222-:22 -device  virtio-net,netdev=user.0 -cdrom output/cloud-data.iso

ssh -i alpine_id_rsa -p 2222 alpine@localhost
```
- To install the image as a template on Proxmox, the following script can be used:
- [Script to download a cloud image and create a Proxmox 6 template](https://gist.github.com/chriswayg/43fbea910e024cbe608d7dcb12cb8466)

### Features
- default user alpine
- add user-data via image drive
- SSH login only via SHH key
- passwordless sudo
- no root login via ssh
  - optional root login via console

### cloud-init features on Alpine
- the fuctionality is not quite complete on Alpine

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
- serial console appears to be buggy, making it hard to log in

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

      Packer v1.5.5
      QEMU emulator version 4.2.0
      Ubuntu 18.04.4 LTS
```

### License and Credits
- Apache 2.0 Copyright 2019 Christian Wagner
- partially based on Matt Maier's [Packer Alpine Templates](https://github.com/maier/packer-templates)
