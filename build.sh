#!/usr/bin/env bash

# 'vm_default_user' and 'vm_memory' will be sourced from build.conf
# and passed as environment variables to Packer
set -o allexport
build_conf="build.conf"

function help {
    printf "\n"
    echo "$0 (proxmox|debug [VM_ID])"
    echo
    echo "proxmox   - Build and create a Proxmox VM template"
    echo "debug     - Debug Mode: Build and create a Proxmox VM template"
    echo
    echo "VM_ID     - VM ID for new VM template (overrides default from build.conf)"
    echo
    echo "Enter Passwwords when prompted or provide them via ENV variables:"
    echo "(use a space in front of ' export' to keep passwords out of bash_history)"
    echo " export proxmox_password=MyLoginPassword"
    echo " export ssh_password=MyPasswordInVM"
    printf "\n"
    exit 0
}

function die_var_unset {
    echo "ERROR: Variable '$1' is required to be set. Please edit '${build_conf}' and set."
    exit 1
}

## check that data in build_conf is complete
[[ -f $build_conf ]] || { echo "User variables file '$build_conf' not found."; exit 1; }
source $build_conf

[[ -z "$vm_default_user" ]] && die_var_unset "vm_default_user"
[[ -z "$default_vm_id" ]] && die_var_unset "default_vm_id"
[[ -z "$iso_url" ]] && die_var_unset "iso_url"
[[ -z "$iso_sha256_url" ]] && die_var_unset "iso_sha256_url"
[[ -z "$iso_directory" ]] && die_var_unset "iso_directory"

## check that build-mode (proxmox|debug) is passed to script
target=${1:-}
[[ "${1}" == "proxmox" ]] || [[ "${1}" == "debug" ]] || help

## VM ID for new VM template (overrides default from build.conf)
vm_id=${2:-$default_vm_id}
printf "\n=> Using VM ID: $vm_id with default user: '$vm_default_user'\n"

## template_name is based on name of current directory, check it exists
template_name="${PWD##*/}.json"

[[ -f $template_name ]] || { echo "Template (${template_name}) not found."; exit 1; }

## check that prerequisites are installed
[[ $(packer --version)  ]] || { echo "Please install 'Packer'"; exit 1; }
[[ $(ansible --version)  ]] || { echo "Please install 'Ansible'"; exit 1; }
[[ $(j2 --version)  ]] || { echo "Please install 'j2cli'"; exit 1; }

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

## download ISO and Ansible role
printf "\n==> Downloading and checking ISO\n\n"
iso_filename=$(basename $iso_url)
wget -P $iso_directory -N $iso_url                  # only re-download when newer on the server
wget --no-verbose $iso_sha256_url -O $iso_directory/SHA256SUMS  # always download and overwrite
(cd $iso_directory && cat $iso_directory/SHA256SUMS | grep $iso_filename | sha256sum --check)
if [ $? -eq 1 ]; then echo "ISO checksum does not match!"; exit 1; fi

printf "\n=> Downloading Ansible role\n\n"
# will always overwrite role to get latest version from Github
ansible-galaxy install --force -p playbook/roles -r playbook/requirements.yml
[[ -f playbook/roles/ansible-initial-server/tasks/main.yml ]] || { echo "Ansible role not found."; exit 1; }

## Insert the password hashes for root and default user to preseed.cfg using a Jinja2 template
# the vm_default_user name will be used by Packer and Ansible
export password_hash1=$(mkpasswd -R 1000000 -m sha-512 $ssh_password)
export password_hash2=$(mkpasswd -R 1000000 -m sha-512 $ssh_password)
export vm_default_user=$vm_default_user

# envsubst '$password_hash1 $password_hash2 $vm_default_user' < preseed.cfg.tmpl > http/preseed.cfg
# j2 is the better solution than 'envsubst' which messes up '$' in the text unless you specify each variable
mkdir -p http
if [[ -f preseed.cfg.j2 ]]; then
    j2 preseed.cfg.j2 > http/preseed.cfg
    [[ -f http/preseed.cfg ]] || { echo "Customized preseed.cfg file not found."; exit 1; }
fi

## Call Packer build with the provided data
case $target in
    proxmox)
        printf "\n==> Build and create a Proxmox template.\n\n"
        # single quotes such as -var 'vm_id=$vm_id' do not work here
        packer build -var iso_filename=$iso_filename -var vm_id=$vm_id -var proxmox_password=$proxmox_password -var ssh_password=$ssh_password $template_name
        ;;
    debug)
        printf "\n==> DEBUG: Build and create a Proxmox template.\n\n"
        PACKER_LOG=1 packer build -debug -on-error=ask -var iso_filename=$iso_filename -var vm_id=$vm_id -var proxmox_password=$proxmox_password -var ssh_password=$ssh_password $template_name
        ;;
    *)
        help
        ;;
esac

## remove preseed.cfg which has the hashed passwords
printf "=> "; rm -v http/preseed.cfg
