set -ex

echo "set hostname plus domainname and add these to /etc/hosts"
namehost=deb10-kvm
namedomain=unassigned.domain
hostnamectl set-hostname ${namehost}
#domainname ${namedomain}
cp -v /etc/hosts /etc/hosts.original
sed -i "/^127.0.1.1/c\127.0.1.1       ${namehost}.${namedomain}  ${namehost}" /etc/hosts

echo "Create a script which will run when the network comes up to display IP before login"

cp -v /etc/issue /etc/issue.original

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
  printf "SSH key fingerprint: \n$(ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub)\n\n" >> /etc/issue
  printf "Server Network Interface: $(ip -4 -br addr |  sed -n '2p')\n\n" >> /etc/issue
fi
EOF

chmod -v +x /etc/network/if-up.d/show-ip-address
