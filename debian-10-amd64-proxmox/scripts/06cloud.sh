set -ex

echo "Enable the serial console"
sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0 console=tty0"' /etc/default/grub

update-grub

echo "Automatically Grow Partition after resize by Proxmox"

cat > /etc/systemd/system/autogrowpart.service << "EOF"
[Unit]
Description=Automatically Grow Partition after resize by Proxmox.

[Service]
Type=simple
ExecStart=/bin/bash /usr/local/bin/auto_grow_partition.sh

[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/autogrowpart.service


cat > /usr/local/bin/auto_grow_partition.sh << "EOF"
#!/bin/bash
growpart -N /dev/sda 1
if [ $? -eq 0 ]; then
    echo "* auto-growing and resizing /dev/sda1"
    growpart /dev/sda 1
    resize2fs /dev/sda1
fi
EOF

chmod +x /usr/local/bin/auto_grow_partition.sh

systemctl enable autogrowpart
