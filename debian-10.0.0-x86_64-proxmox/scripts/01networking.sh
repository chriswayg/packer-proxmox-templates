set -ex

echo "Create a script which will run when the network comes up to display IP before login"

cp /etc/issue /etc/issue.original

cat > /etc/network/if-up.d/show-ip-address << "EOF"
#!/bin/sh
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
echo "SSH key fingerprint: \n$(ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub)" >> /etc/issue
echo ""  >> /etc/issue
echo "Server IP: $(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')" >> /etc/issue
echo ""  >> /etc/issue
fi
EOF

chmod +x /etc/network/if-up.d/show-ip-address
