set -eux

apk add py3-zipp@edge
apk add py3-importlib-metadata@edgecommunity
apk add cloud-init@testing

# install missing dependencies
apk add eudev

# needed for 'growpart'
apk add cloud-utils@testing

# install utils
apk add acpi
apk add nano

# make sure CD drive with cloud-init config data gets mounted
# /dev/sr0        /media/cdrom    iso9660 ro 0 0
sed -i 's/\/dev\/cdrom/\/dev\/sr0/g' /etc/fstab
sed -i 's/noauto,ro/ro/g' /etc/fstab

# writing of network config is not implemented in alpine cloud-init
#apk add iproute2 ifupdown
echo "network: {config: disabled}" > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg

# Start Cloud-Init on Boot
rc-update add cloud-init default

# enable automatically growing the partition
cat > /etc/cloud/cloud.cfg.d/10_growpart.cfg << "EOF"
growpart:
  mode: growpart
  devices: ["/dev/sda2"]
  ignore_growroot_disabled: false

# the above settings do not seem to get used, thus run growpart here
bootcmd:
 - growpart /dev/sda 2
EOF

# activate serial console
# it is buggy, as it makes it hard to log in

# sed -i 's/quiet/console=ttyS0,9600/g' /etc/update-extlinux.conf
# update-extlinux
#
# sed -i 's/#ttyS0/ttyS0/g' /etc/inittab
