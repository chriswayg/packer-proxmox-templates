variable "template_description" {
  type    = string
  default = "Alpine Linux 3.11 x86_64 template built with packer (${env("vm_ver")}). Username: ${env("default_vm_user")}"
}

variable "vm_id" {
  type    = string
  default = "${env("vm_id")}"
}

variable "vm_name" {
  type    = string
  default = "alpine3-tmpl"
}

variable "vm_memory" {
  type    = string
  default = "${env("vm_memory")}"
}

variable "ansible_verbosity" {
  type    = string
  default = "${env("ansible_verbosity")}"
}

variable "default_vm_user" {
  type    = string
  default = "${env("default_vm_user")}"
}

variable "iso_filename" {
  type    = string
  default = "${env("iso_filename")}"
}

variable "proxmox_host" {
  type    = string
  default = "${env("proxmox_host")}"
}

variable "proxmox_username" {
  type    = string
  default = "${env("proxmox_user")}@pam"
}

variable "proxmox_password" {
  type      = string
  default   = "${env("proxmox_password")}"
  sensitive = true
}

variable "proxmox_url" {
  type    = string
  default = "${env("proxmox_url")}"
}

variable "proxmox_net_int" {
  type    = string
  default = "${env("proxmox_net_int")}"
}

variable "proxmox_net_vlan_tag" {
  type    = string
  default = "${env("proxmox_net_vlan_tag")}"
}

variable "proxmox_storage_vm" {
  type    = string
  default = "${env("proxmox_storage_vm")}"
}

variable "proxmox_storage_iso" {
  type    = string
  default = "${env("proxmox_storage_iso")}"
}

variable "ssh_username" {
  type    = string
  default = "root"
}

variable "ssh_password" {
  type      = string
  default   = "${env("ssh_password")}"
  sensitive = true
}

source "proxmox" "instance" {
  template_description = "${var.template_description}"
  vm_id                = "${var.vm_id}"
  vm_name              = "${var.vm_name}"
  cores                = "2"
  memory               = "${var.vm_memory}"
  node                 = "${var.proxmox_host}"
  os                   = "l26"
  proxmox_url          = "${var.proxmox_url}"
  username             = "${var.proxmox_username}"
  password             = "${var.proxmox_password}"
  ssh_username         = "${var.ssh_username}"
  ssh_password         = "${var.ssh_password}"
  ssh_timeout          = "15m"
  qemu_agent           = true

  http_directory       = "http"
  insecure_skip_tls_verify = true
  iso_file             = "${var.proxmox_storage_iso}:iso/${var.iso_filename}"
  unmount_iso          = true

  scsi_controller      = "virtio-scsi-pci"
  disks {
    disk_size          = "8G"
    format             = "qcow2"
    storage_pool       = "${var.proxmox_storage_vm}"
    storage_pool_type  = "directory"
    type               = "sata"
  }
  boot_command = [
    "root<enter><wait>", 
    "ifconfig eth0 up && udhcpc -i eth0<enter><wait5>", 
    "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/answers<enter><wait>", 
    "setup-alpine -f $PWD/answers<enter><wait5>", 
    "${var.ssh_password}<enter><wait>", 
    "${var.ssh_password}<enter><wait>", 
    "<wait10><wait5>", 
    "y<enter>", 
    "<wait10><wait10>", 
    "rc-service sshd stop <enter>", 
    "mount /dev/sda2 /mnt <enter>", 
    "mount /dev/ /mnt/dev/ --bind <enter>", 
    "mount -t proc none /mnt/proc <enter>", 
    "mount -o bind /sys /mnt/sys <enter>", 
    "chroot /mnt /bin/sh -l <enter><wait>", 
    "echo '@edgecommunity http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories <enter>", 
    "echo -e 'nameserver 1.1.1.1' > /etc/resolv.conf <enter>", 
    "apk update <enter><wait10>", 
    "apk add 'qemu-guest-agent' 'python' 'sudo' <enter><wait>", 
    "echo -e GA_PATH=\"/dev/vport1p1\" >> /etc/conf.d/qemu-guest-agent <enter>", 
    "rc-update add qemu-guest-agent <enter>", 
    "echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config <enter>", 
    "exit <enter><wait>", 
    "umount /mnt/sys <enter><wait>", 
    "umount /mnt/proc <enter><wait>", 
    "umount /mnt/dev <enter><wait>", 
    "umount /mnt <enter>", 
    "reboot <enter>"
  ]
  boot_wait    = "10s"

  network_adapters {
    bridge             = "${var.proxmox_net_int}"
    model              = "virtio"
    vlan_tag           = "${var.proxmox_net_vlan_tag}"
  }
}

build {
  description = "Build Alpine Linux 3 x86_64 Proxmox template"

  sources = ["source.proxmox.instance"]

  provisioner "ansible" {
    ansible_env_vars   = ["ANSIBLE_CONFIG=./playbook/ansible.cfg", "ANSIBLE_FORCE_COLOR=True"]
    extra_arguments    = ["${var.ansible_verbosity}", "--extra-vars", "default_vm_user=${var.default_vm_user}", "--tags", "all,is_template", "--skip-tags", "debuntu,openbsd"]
    playbook_file      = "./playbook/server-template.yml"
  }

  post-processor "shell-local" {
    inline             = ["qm set ${var.vm_id} --serial0 socket --vga serial0"]
    inline_shebang     = "/bin/bash -e"
  }
}
