set -eux

# install prerequisites for cloud-utils
apk add nettle@edge  # A low-level cryptographic library
apk add gnutls@edge  # A TLS protocol implementation

# includes 'growpart'
apk add cloud-utils@testing

# install utils
apk add acpi # ACPI client for battery, power, and thermal readings
apk add nano

# creates a growpart script which will run on startup
cat > /etc/local.d/05_auto_grow_partition.start << "EOF"
#!/bin/sh
growpart -N /dev/sda 2
if [ $? -eq 0 ]; then
    echo "* auto-growing and resizing /dev/sda2"
    growpart /dev/sda 2
    resize2fs /dev/sda2
fi
EOF
chmod +x /etc/local.d/05_auto_grow_partition.start

rc-update add local default

# this prevents lots of tty messages to be logged to syslog
sed -i 's/^tty/# tty/g' /etc/inittab

# activate serial console
sed -i 's/quiet/console=ttyS0,9600/g' /etc/update-extlinux.conf
update-extlinux
sed -i 's/#ttyS0/ttyS0/g' /etc/inittab
