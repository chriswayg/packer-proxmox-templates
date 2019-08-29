#!/usr/bin/env bash
build_conf="build.conf"

function pause(){
   read -p "$*"
}

function help {
    echo "$0 (proxmox|debug [VM_ID])"
    echo
    echo "proxmox   - Build and create a Proxmox VM template"
    echo "debug     - Debug Mode: Build and create a Proxmox VM template"
    echo
    echo "VM_ID     - VM ID for new VM template (or use default from build.conf)"
    echo
    echo " export proxmox_password=MyLoginPassword (or enter it when prompted)"
    exit 0
}

function die_var_unset {
    echo "ERROR: Variable '$1' is required to be set. Please edit '${build_conf}' and set."
    exit 1
}

PACKER=$(type -P packer)
[[ $? -eq 0 && -n "$PACKER" ]] || { echo "Unable to find 'packer' command"; exit 1; }

target=${1:-}
[[ -z "$target" ]] && help

[[ -f $build_conf ]] || { echo "User variables file '$build_conf' not found."; exit 1; }
source $build_conf

[[ -z "$vm_id" ]] && die_var_unset "vm_id"
[[ -z "$iso_url" ]] && die_var_unset "iso_url"
[[ -z "$iso_sha256_url" ]] && die_var_unset "iso_sha256_url"
[[ -z "$iso_directory" ]] && die_var_unset "iso_directory"

new_vmid=${2:-$vm_id}
printf "\nUsing VM ID: $new_vmid\n"

# based on name of current directory
template_name="${PWD##*/}.json"

[[ -f $template_name ]] || { echo "Template (${template_name}) not found."; exit 1; }

# If not set in env variable, prompt for it
[[ -z "$proxmox_password" ]] && read -s -p "Existing PROXMOX Login Password: " proxmox_password && printf "\n"
printf "\n"

while true; do
    read -s -p "Record New User Password: " ssh_password
    printf "\n"
    read -s -p "Repeat New User Password: " ssh_password2
    printf "\n"
    [ "$ssh_password" = "$ssh_password2" ] && break
    printf "Passwords do not match. Please try again!\n\n"
done

[[ -z "$proxmox_password" ]] && echo "The Proxmox Password is required." && exit 1
[[ -z "$ssh_password" ]] && echo "The User Password is required." && exit 1

printf "\n* Downloading and checking ISO ***\n\n"
iso_name=$(basename $iso_url)
wget -P $iso_directory -N $iso_url                  # only re-download when newer on the server
wget --no-verbose $iso_sha256_url -O $iso_directory/SHA256SUMS  # always download and overwrite
(cd $iso_directory && cat $iso_directory/SHA256SUMS | grep $iso_name | sha256sum --check)
if [ $? -eq 1 ]; then echo "ISO checksum does not match"; exit 1; fi

# temporarily append the password hash to preseed.cfg
password_hash=$(mkpasswd -R 1000000 -m sha-512 $ssh_password)
echo "d-i passwd/user-password-crypted password $password_hash" >> http/preseed.cfg

case $target in
    proxmox)
        printf "\n*** Build and create a Proxmox template. ***\n\n"
        # single quotes such as -var 'prox_pass=$proxmox_password' do not work here
        packer build -var iso_name=$iso_name -var prox_vmid=$new_vmid -var prox_pass=$proxmox_password -var ssh_pass=$ssh_password $template_name
        ;;
    debug)
        printf "\n*** Debug: Build and create a Proxmox template. ***\n\n"
        PACKER_LOG=1 packer build -debug -on-error=ask -var iso_name=$iso_name -var prox_vmid=$new_vmid -var prox_pass=$proxmox_password -var ssh_pass=$ssh_password $template_name
        ;;
    *)
        help
        ;;
esac

# remove the hashed password, so it does not get stored in git
sed -i '/^d-i passwd\/user-password-crypted/d' http/preseed.cfg
