set -eux

# install cloud-init
# apk add py3-zipp@edge
# apk add py3-importlib-metadata@edgecommunity
# apk add cloud-init@testing

# Start Cloud-Init on Boot
#rc-update add cloud-init default

# make sure CD drive with cloud-init config data gets mounted
# /dev/sr0        /media/cdrom    iso9660 ro 0 0
#sed -i 's/\/dev\/cdrom/\/dev\/sr0/g' /etc/fstab
#sed -i 's/noauto,ro/ro/g' /etc/fstab

# writing of network config is not implemented in alpine cloud-init
#apk add iproute2 ifupdown
# echo "network: {config: disabled}" > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg

# enable automatically growing the partition
# cat > /etc/cloud/cloud.cfg.d/10_growpart.cfg << "EOF"
# growpart:
#   mode: growpart
#   devices: ["/dev/sda2"]
#   ignore_growroot_disabled: false
#
# # the above settings do not seem to get used, thus run growpart here
# bootcmd:
#  - growpart /dev/sda 2
# EOF

# install prerequisites for cloud-utils
#apk add eudev        # OpenRC compatible fork of systemd-udev
apk add nettle@edge  # A low-level cryptographic library
apk add gnutls@edge  # A TLS protocol implementation

# includes 'growpart'
apk add cloud-utils@testing

# install utils
apk add acpi # ACPI client for battery, power, and thermal readings
apk add nano

# creates a growpart script which will run on startup
cat > /etc/local.d/auto_grow_partition.start << "EOF"
#!/bin/sh
growpart -N /dev/sda 2
if [ $? -eq 0 ]; then
    echo "* auto-growing and resizing /dev/sda2"
    growpart /dev/sda 2
    resize2fs /dev/sda2
fi
EOF
chmod +x /etc/local.d/auto_grow_partition.start

# activate serial console
# it is buggy, as it makes it hard to log in

# sed -i 's/quiet/console=ttyS0,9600/g' /etc/update-extlinux.conf
# update-extlinux
#
# sed -i 's/#ttyS0/ttyS0/g' /etc/inittab
