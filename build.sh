#!/usr/bin/env bash

# Many variables are sourced from build.conf and passed as environment variables to Packer.
# The default_vm_user name will be used by Packer and Ansible.
# (j2 is a better solution than 'envsubst' which messes up '$' in the text unless you specify each variable)
# default_vm_user
# vm_memory
# proxmox_host
# iso_filename
# vm_ver
# vm_id
# proxmox_password
# ssh_password

set -o allexport
build_conf="build.conf"

## check that prerequisites are installed
[[ $(packer --version)  ]] || { echo "Please install 'Packer'"; exit 1; }
[[ $(ansible --version)  ]] || { echo "Please install 'Ansible'"; exit 1; }
[[ $(j2 --version)  ]] || { echo "Please install 'j2cli'"; exit 1; }

# Import functions
source ../functions.sh

## check that data in build_conf is complete
[[ -f $build_conf ]] || { echo "User variables file '$build_conf' not found."; exit 1; }
source $build_conf

[[ -z "$default_vm_id" ]] && die_var_unset "default_vm_id"
[[ -z "$default_vm_user" ]] && die_var_unset "default_vm_user"
[[ -z "$vm_memory" ]] && die_var_unset "vm_memory"
[[ -z "$proxmox_url" ]] && die_var_unset "proxmox_url"
[[ -z "$proxmox_host" ]] && die_var_unset "proxmox_host"
[[ -z "$proxmox_user" ]] && die_var_unset "proxmox_user"
[[ -z "$proxmox_storage_vm" ]] && die_var_unset "proxmox_storage_vm"
[[ -z "$proxmox_storage_iso" ]] && die_var_unset "proxmox_storage_iso"
[[ -z "$proxmox_net_int" ]] && die_var_unset "proxmox_net_int"
[[ -z "$iso_url" ]] && die_var_unset "iso_url"
[[ -z "$iso_sha256_url" ]] && die_var_unset "iso_sha256_url"

## check that build-mode (proxmox|debug) is passed to script
target=${1:-}
[[ "${1}" == "proxmox" ]] || [[ "${1}" == "debug" ]] || help

## VM ID for new VM template (overrides default from build.conf)
vm_id=${2:-$default_vm_id}
printf "\n==> Using VM ID: $vm_id with default user: '$default_vm_user'\n"

## template_name is based on name of current directory, check it exists
#template_name="${PWD##*/}.json"
template_name="${PWD##*/}.pkr.hcl"

[[ -f $template_name ]] || { echo "Template (${template_name}) not found."; exit 1; }

## If passwords are not set in env variable, prompt for them
[[ -z "$proxmox_password" ]] && printf "\n" && read -s -p "Existing PROXMOX Login Password: " proxmox_password && printf "\n"
printf "\n"

if [[ -z "$ssh_password" ]]; then
    while true; do
        read -s -p "Enter  new SSH Password: " ssh_password
        printf "\n"
        read -s -p "Repeat new SSH Password: " ssh_password2
        printf "\n"
        [ "$ssh_password" = "$ssh_password2" ] && break
        printf "Passwords do not match. Please try again!\n\n"
    done
fi

[[ -z "$proxmox_password" ]] && echo "The Proxmox Password is required." && exit 1
[[ -z "$ssh_password" ]] && echo "The SSH Password is required." && exit 1

## Download ISO and Ansible role
printf "==> Downloading and checking ISO\n"
iso_filename=$(basename $iso_url)
if [ -n $iso_directory ]; then
  # Download ISO to temporary directory locally for upload later
  download_iso "/tmp"
  # Get cookie and token from ProxMox API
  cookie=`curl -s -k --data "username=${proxmox_user}@pam&password=${proxmox_password}" \
    ${proxmox_url}/access/ticket | jq --raw-output '.data.ticket'`
  token=`curl -s -k --data "username=${proxmox_user}@pam&password=${proxmox_password}" \
    ${proxmox_url}/access/ticket | jq --raw-output '.data.CSRFPreventionToken'`
  # Get timestamp of iso if exist
  remote_iso_timestamp=`get_remote_iso_timestamp`
  if [ "${remote_iso_timestamp}" == "" ]; then
    printf "\n==> ISO not found on remote server: $proxmox_host"
    printf "\n==> Uploading $iso_filename to $proxmox_host"
    put_remote_iso
  else
    printf "\n==> ISO found on remote server: $proxmox_host with timestamp of $remote_iso_timestamp"
    local_iso_timestamp=`date +%s -r /tmp/$iso_filename`
    if [ $remote_iso_timestamp -lt $local_iso_timestamp ]; then
      printf "\n==> Uploading newer version of $iso_filename to $proxmox_host"
      put_remote_iso
    else
      printf "\n==> Remote ISO is newer, not uploading"
    fi
  fi
else
  download_iso "$iso_directory"
fi

mkdir -p ../roles
printf "\n==> Downloading latest Ansible role\n\n"
# will always overwrite role to get latest version from Github
ansible-galaxy install --force -p ../roles -r playbook/requirements.yml
[[ -f ..//roles/ansible-initial-server/tasks/main.yml ]] || { echo "Ansible role not found."; exit 1; }

mkdir -p http

# Debian & Ubuntu
## Insert the password hashes for root and default user into preseed.cfg using a Jinja2 template
if [[ -f preseed.cfg.j2 ]]; then
    password_hash1=$(mkpasswd -R 1000000 -m sha-512 $ssh_password)
    password_hash2=$(mkpasswd -R 1000000 -m sha-512 $ssh_password)
    printf "\n==> Customizing auto preseed.cfg\n"
    j2 preseed.cfg.j2 > http/preseed.cfg
    [[ -f http/preseed.cfg ]] || { echo "Customized preseed.cfg file not found."; exit 1; }
fi

# OpenBSD
## Insert the password hashes for root and default user into install.conf using a Jinja2 template
if [[ -f install.conf.j2 ]]; then
    password_hash1=$(python3 -c "import os, bcrypt; print(bcrypt.hashpw(str(os.environ['ssh_password']).encode('utf-8'), bcrypt.gensalt(10)))" | sed -e "s/b'//g" | sed -e "s/'//")
    password_hash2=$(python3 -c "import os, bcrypt; print(bcrypt.hashpw(str(os.environ['ssh_password']).encode('utf-8'), bcrypt.gensalt(10)))" | sed -e "s/b'//g" | sed -e "s/'//")
    printf "\n=> Customizing install.conf\n"
    j2 install.conf.j2 > http/install.conf
    [[ -f http/install.conf ]] || { echo "Customized install.conf file not found."; exit 1; }
fi

vm_ver=$(git describe --tags)


## Call Packer build with the provided data
case $target in
    proxmox)
        printf "\n==> Build and create a Proxmox template.\n\n"
        ansible_verbosity="-v"
        packer build $template_name
        ;;
    debug)
        printf "\n==> DEBUG: Build and create a Proxmox template.\n\n"
        ansible_verbosity="-vvvv"
        PACKER_LOG=1 packer build -debug -on-error=ask $template_name
        ;;
    *)
        help
        ;;
esac

# Update VM Config options, used to be part of the post processors for packer
printf "\n==> Updating Config options for Proxmox template $vm_id.\n\n"
update_vm_config

## remove file which has the hashed passwords
[[ -f http/preseed.cfg ]] && printf "=> " && rm -v http/preseed.cfg
[[ -f http/install.conf ]] && printf "=> " && rm -v http/install.conf
