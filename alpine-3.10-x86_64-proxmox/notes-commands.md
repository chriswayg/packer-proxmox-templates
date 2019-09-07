## scratchpad

# boot command:
openntpd missing (error)

## Misc. Notes

- Build Packer template
```
cd /home/christian/developer/projects/packer-qemu-cloud/alpine3.10-qemu
sudo PACKER_LOG=1 packer build alpine-3.10-x86_64-qemu.json
```

- Alpine boot kernel 'virt' with randomness from CPU & info during boot for testing
```
virt random.trust_cpu=1 debug
```

- start a VM with access via ssh -p 2222 root@127.0.0.1 for testing
```
sudo qemu-system-x86_64 output-qemu/packer-qemu -netdev  user,id=user.0,hostfwd=tcp::2222-:22 -device  virtio-net,netdev=user.0 -cdrom  config.iso
```

- apparently all device arguments have to be together to work
```
"qemuargs": [
  [ "-device", "virtio-rng-pci" ],
  [ "-device", "virtio-scsi-pci,id=scsi0" ],
  [ "-device", "scsi-hd,bus=scsi0.0,drive=drive0" ],
  [ "-device", "virtio-net,netdev=user.0" ]
],
```
