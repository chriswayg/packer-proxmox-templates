## scratchpad

# boot command:
openntpd missing (error)


# add:

echo "@edgecommunity http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /mnt/etc/apk/repositories

#chroot
mount /dev/ /mnt/dev/ --bind
mount -o remount,ro,bind /mnt/dev
chroot /mnt /bin/bash -l
apk add qemu-guest-agent@edgecommunity
rc-update add qemu-guest-agent

host:~# cat /etc/conf.d/qemu-guest-agent
# Specifies the transport method used to communicate to QEMU on the host side
# Default: virtio-serial
#GA_METHOD="virtio-serial"

# Specifies the device path for the communications back to QEMU on the host
# Default: /dev/virtio-ports/org.qemu.guest_agent.0
GA_PATH="/dev/vport1p1"
