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

### Default VM Numbers
- 10000 Debian 8
- 11000 Debian 9
- 12000 Debian 10
- 20000 Ubuntu 18.04
- 21000 Ubuntu 20.04
- 22000 Ubuntu 22.04
- 31000 Centos 7
- 40000 Alpine 3.11
- 42000 Arch
- 44000 RancherOS 1.5.5
- 46000 CoreOS/Flatcar
- 47000 OpenBSD

### Default Cloud VM Numbers
- 51000 Debian 8
- 51100 Debian 9
- 51200 Debian 10
- 52000 Ubuntu 18.04
- 52100 Ubuntu 20.04
- 52200 Ubuntu 22.04
- 53100 Centos 7
- 54000 Alpine 3.11
- 54200 Arch
- 54400 RancherOS 1.5.5
- 54600 CoreOS/Flatcar
