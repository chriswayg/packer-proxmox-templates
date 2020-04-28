# Check the functionality of features

### Check that services are enabled

```
# Debian/Ubuntu
systemctl list-unit-files | grep -E 'autogrowpart|ssh-host-keygen'

# Alpine
rc-status | grep 'local '
```

### Check that autogrow partition works (all OS)

- check disk space
```
df -h
reboot
```

- increase disk size in Proxmox and check disk space again
```
df-h
```

### Check ssh-host-keygen

- create two clones in Proxmox
- check fingerprints

### Ansible Playbook

- run the playbook again on a clone
