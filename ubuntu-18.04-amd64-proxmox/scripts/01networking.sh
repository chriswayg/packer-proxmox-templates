set -ex

echo "Create a script which will run when the network comes up to display IP before login"

cp /etc/issue /etc/issue.original

cat > /etc/networkd-dispatcher/routable.d/99-show-ip-address << "EOF"
#!/bin/bash
cp /etc/issue.original /etc/issue
printf "SSH key fingerprint: \n$(ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub)\n\n" >> /etc/issue
printf "Server Network Interface: $(ip -4 -br addr |  sed -n '2p')\n\n" >> /etc/issue
EOF

chmod +x /etc/networkd-dispatcher/routable.d/99-show-ip-address
