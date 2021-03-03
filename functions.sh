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

function download_iso {
  mkdir logs >/dev/null 2>&1
  if [ "$target" == "proxmox" ]; then
    wget -P ${1} -N $iso_url >>logs/wget.log 2>&1                # only re-download when newer on the server
    wget --no-verbose $iso_sha256_url -O ${1}/SHA256SUMS >>logs/wget.log 2>&1 # always download and overwrite
  else
    wget -P ${1} -N $iso_url                 # only re-download when newer on the server
    wget --no-verbose $iso_sha256_url -O ${1}/SHA256SUMS  # always download and overwrite
  fi
  (cd ${1} && cat ${1}/SHA256SUMS | grep $iso_filename | sha256sum --check)
  if [ $? -eq 1 ]; then echo "ISO checksum does not match!"; exit 1; fi
}

function get_remote_iso_timestamp {
  curl -s -k  \
    -H "Cookie: PVEAuthCookie=$cookie" \
    -H "Csrfpreventiontoken: $token"\
    ${proxmox_url}/nodes/${proxmox_host}/storage/${proxmox_storage_iso}/content | jq ".data[]| select(.volid==\"${proxmox_storage_iso}:iso/$iso_filename\") | .ctime"
}

function put_remote_iso {
  # TODO: Add logging and checking for errors
  curl -s -k -X POST \
    -H "Content-type: multipart/form-data" \
    -H "Cookie: PVEAuthCookie=$cookie" \
    -H "Csrfpreventiontoken: $token"\
    --form "content=iso" \
    --form "filename=@/tmp/${iso_filename}" \
    ${proxmox_url}/nodes/${proxmox_host}/storage/${proxmox_storage_iso}/upload >/dev/null
}

function update_vm_config {
  # TODO: Add logging and checking for errors
  curl -s -k -X POST \
    -H "Cookie: PVEAuthCookie=$cookie" \
    -H "Csrfpreventiontoken: $token"\
    --data "serial0=socket" \
    --data "vga=serial0" \
    --data "scsihw=virtio-scsi-pci" \
    ${proxmox_url}/nodes/${proxmox_host}/qemu/${vm_id}/config >/dev/null
}
