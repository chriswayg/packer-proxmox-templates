## scratchpad

# boot command:
openntpd missing (error)



## Misc. Notes

- Alpine boot kernel 'virt' with randomness from CPU & info during boot for testing
```
virt random.trust_cpu=1 debug
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
