# command used by Packer to run ansible playbook

ansible-playbook /root/packer-projects/ubuntu-18.04-amd64-proxmox/playbook/server-template.yml
    -vv
    --inventory-file /tmp/packer-provisioner-ansible121990355
    --extra-vars
      packer_build_name=proxmox
      packer_builder_type=proxmox
      packer_http_addr=217.79.184.184:8320
      vm_default_user=chris
      ansible_ssh_private_key_file=/tmp/ansible-key088836676
    -o IdentitiesOnly=yes # SSH option
