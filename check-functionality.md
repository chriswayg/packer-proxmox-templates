# Check the functionality of features

### Check that services are enabled

```
# Debian/Ubuntu
systemctl list-unit-files | grep -E 'autogrowpart|ssh-host-keygen'

systemctl status ssh-host-keygen
systemctl status autogrowpart

# Alpine
rc-status | grep 'local '
```

### Check that autogrow partition works (all OS)

- check disk space
```
df -h
poweroff
```

- increase disk size in Proxmox and check disk space again
```
df-h
```

### Check ssh-host-keygen

- create two clones in Proxmox
- check fingerprints

###
- check ssh login

`ssh -p 3XX22 christian@proxmox.lightinasia.site`

### Ansible Playbook

- run the playbook again on a clone
