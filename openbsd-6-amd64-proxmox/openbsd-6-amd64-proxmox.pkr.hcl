variable "template_description" {
  type    = string
  default = "OpenBSD 6 x86_64 template built with packer (${env("vm_ver")}). Username: ${env("default_vm_user")}"
}

variable "vm_id" {
  type    = string
  default = "${env("vm_id")}"
}

variable "vm_name" {
  type    = string
  default = "openbsd6-tmpl"
}

variable "vm_memory" {
  type    = string
  default = "${env("vm_memory")}"
}

variable "vm_default_ip" {
  type    = string
  default = "${env("vm_default_ip")}"
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
  os                   = "other"
  proxmox_url          = "${var.proxmox_url}"
  username             = "${var.proxmox_username}"
  password             = "${var.proxmox_password}"
  ssh_username         = "${var.ssh_username}"
  ssh_password         = "${var.ssh_password}"
  ssh_timeout          = "15m"
  ssh_host             = "${var.vm_default_ip}"
  http_directory       = "http"
  insecure_skip_tls_verify = true
  iso_file             = "${var.proxmox_storage_iso}:iso/${var.iso_filename}"
  unmount_iso          = true
  qemu_agent           = false

  scsi_controller      = "virtio-scsi-pci"
  disks {
    disk_size          = "8G"
    format             = "qcow2"
    storage_pool       = "${var.proxmox_storage_vm}"
    storage_pool_type  = "directory"
    type               = "scsi"
  }
  boot_command = ["a<enter><wait>", "<wait5>", "http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.conf<enter><wait>", "<wait5>", "i<enter><wait>"]
  boot_wait    = "30s"

  network_adapters {
    bridge             = "${var.proxmox_net_int}"
    model              = "virtio"
    vlan_tag           = "${var.proxmox_net_vlan_tag}"
  }
}

build {
  description = "Build OpenBSD 6 x86_64 Proxmox template"

  sources = ["source.proxmox.instance"]

  provisioner "ansible" {
    ansible_env_vars   = ["ANSIBLE_CONFIG=./playbook/ansible.cfg", "ANSIBLE_FORCE_COLOR=True"]
    extra_arguments    = ["${var.ansible_verbosity}", "--extra-vars", "default_vm_user=${var.default_vm_user}", "--tags", "all,is_template", "--skip-tags", "debuntu,alpine"]
    playbook_file      = "./playbook/server-template.yml"
  }
}
