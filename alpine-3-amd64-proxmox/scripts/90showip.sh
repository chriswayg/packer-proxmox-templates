# show SSH key fingerprint and IP address on console

cp /etc/issue /etc/issue-standard

# Creates a script which will run when the network comes up
cat > /etc/network/if-up.d/show-ip-address << "EOF"
#!/bin/sh
if [ "$METHOD" = loopback ]; then
    exit 0
fi

# Only run from ifup.
if [ "$MODE" != start ]; then
    exit 0
fi

cp /etc/issue-standard /etc/issue
printf "ECDSA key fingerprint:\n$(ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub)\n" >> /etc/issue
printf "\nSSH user: christian     IP: $(ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')\n\n" >> /etc/issue

EOF

chmod +x /etc/network/if-up.d/show-ip-address
