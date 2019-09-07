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
printf "\nSSH user: alpine     Server IP: $(ip -o route get to 1.1.1.1 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')\n\n" >> /etc/issue
EOF

chmod +x /etc/network/if-up.d/show-ip-address
