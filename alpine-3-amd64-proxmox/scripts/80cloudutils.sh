set -eux

# MOVED TO ANSIBLE

# install packages
apk add nano
apk add nettle@edge     # A low-level cryptographic library (prereq for cloud-utils)
apk add gnutls@edge     # A TLS protocol implementation (prereq for cloud-utils)
apk add cloud-utils@testing # Useful set of utilities for interacting with a cloud (growpart)
apk add e2fsprogs-extra # Ext2/3/4 filesystem extra utilities (resize2fs)

# creates a growpart script which will run on startup
cat > /etc/local.d/05_auto_grow_partition.start << "EOF"
#!/bin/sh
date  >>/var/log/growpart 2>&1
growpart -N /dev/sda 2 >>/var/log/growpart 2>&1
if [ $? -eq 0 ]; then
    echo "* auto-growing and resizing /dev/sda2" >>/var/log/growpart 2>&1
    growpart /dev/sda 2 >>/var/log/growpart 2>&1
    resize2fs /dev/sda2 >>/var/log/growpart 2>&1
fi
EOF
chmod -v +x /etc/local.d/05_auto_grow_partition.start

rc-update add local default

# activate serial console
sed -i 's/quiet/console=ttyS0,9600/g' /etc/update-extlinux.conf
update-extlinux

# prevent lots of tty messages to be logged to syslog, only use serial console
sed -i 's/^tty/# tty/g' /etc/inittab
sed -i 's/#ttyS0/ttyS0/g' /etc/inittab
