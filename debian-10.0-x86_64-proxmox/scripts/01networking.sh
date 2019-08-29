set -ex

echo "Create a script which will run when the network comes up to display IP before login"

cp /etc/issue /etc/issue.original

cat > /etc/network/if-up.d/show-ip-address << "EOF"
#!/bin/bash
if [ "$METHOD" = loopback ]; then
    exit 0
fi

# Only run from ifup.
if [ "$MODE" != start ]; then
    exit 0
fi

# Only run from main interface.
if [ "$IFACE" = ens18 ]; then
cp /etc/issue.original /etc/issue
#printf "Method: $METHOD, Mode: $MODE,  Interface: $IFACE\n\n" >> /etc/issue
printf "SSH key fingerprint: \n$(ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub)\n\n" >> /etc/issue
printf "Server Network Interface: $(ip -4 -br addr |  sed -n '2p')\n\n" >> /etc/issue
fi
EOF

chmod +x /etc/network/if-up.d/show-ip-address
